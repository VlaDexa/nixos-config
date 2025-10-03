{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/pull/1058/head";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-parts.follows = "flake-parts";
      # Only used during lanzaboote development
      inputs.pre-commit-hooks-nix.follows = "";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    nixvim-config = {
      url = "github:VlaDexa/nixvim-config";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixvim.follows = "nixvim";
    };
    # Temporary patcher until https://github.com/NixOS/nix/issues/3920 is resolved
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    nixpkgs-patch-414391 = {
      url = "https://github.com/NixOS/nixpkgs/pull/414391.patch";
      flake = false;
    };
    dolphin-overlay = {
      url = "github:rumboon/dolphin-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      plasma-manager,
      nixos-hardware,
      disko,
      sops-nix,
      nur,
      lanzaboote,
      pre-commit-hooks,
      nix-index-database,
      nixvim,
      nixvim-config,
      nixpkgs-patcher,
      dolphin-overlay,
      ...
    }@inputs:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      nixosConfigurations =
        let
          shared_home_modules = [
            plasma-manager.homeModules.plasma-manager
            sops-nix.homeManagerModules.sops
            {
              sops.defaultSopsFile = ./secrets.yaml;
            }
            nix-index-database.homeModules.nix-index
            nixvim.homeModules.nixvim
            {
              programs.nixvim = nixvim-config.modules.config;
            }
            ./modules/programs
          ];
          shared_modules = [
            nur.modules.nixos.default
            home-manager.nixosModules.home-manager
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            {
              sops.defaultSopsFile = ./secrets.yaml;
            }
            ./cachix.nix
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = shared_home_modules;
              home-manager.backupFileExtension = "backup";
            }
            ./nixosConfigs/shared/configuration.nix
            ./modules/plymouth.nix
            ./modules/services/arangodb.nix
            lanzaboote.nixosModules.lanzaboote
            ./secure-boot.nix
            {
              nixpkgs.overlays = [ dolphin-overlay.overlays.default ];
            }
          ];
          vladexa = {
            home-manager.users.vladexa = ./nixosConfigs/shared/home/vladexa.nix;
          };
        in
        {
          nixos = nixpkgs-patcher.lib.nixosSystem {
            specialArgs = inputs;
            modules = shared_modules ++ [
              ./nixosConfigs/laptop
              nixos-hardware.nixosModules.common-cpu-amd
              nixos-hardware.nixosModules.common-cpu-amd-pstate
              nixos-hardware.nixosModules.common-cpu-amd-zenpower
              nixos-hardware.nixosModules.common-gpu-amd
              nixos-hardware.nixosModules.common-hidpi
              nixos-hardware.nixosModules.common-pc-laptop
              nixos-hardware.nixosModules.common-pc-ssd
              vladexa
            ];
          };

          workstation = nixpkgs-patcher.lib.nixosSystem {
            specialArgs = inputs;
            modules = shared_modules ++ [
              ./nixosConfigs/workstation
              nixos-hardware.nixosModules.common-cpu-amd
              nixos-hardware.nixosModules.common-cpu-amd-pstate
              nixos-hardware.nixosModules.common-cpu-amd-zenpower
              nixos-hardware.nixosModules.common-gpu-amd
              nixos-hardware.nixosModules.common-hidpi
              nixos-hardware.nixosModules.common-pc-ssd
              vladexa
            ];
          };
        };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);

      checks = forAllSystems (system: {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
          };
        };
      });

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            inherit (self.checks.${system}.pre-commit-check) shellHook;
            buildInputs = with pkgs; [ nil ] ++ self.checks.${system}.pre-commit-check.enabledPackages;
          };
        }
      );

      packages = forAllSystems (system: {
        nixos-options-doc =
          (nixpkgs.legacyPackages.${system}.nixosOptionsDoc {
            inherit (self.nixosConfigurations.workstation) options;
          }).optionsCommonMark;
      });
    };
}

# vim: ts=2 sw=2 et:
