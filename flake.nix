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
      url = "github:nix-community/disko";
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
      url = "github:nix-community/lanzaboote/v0.4.3";
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
      # Only for dev
      inputs.pre-commit-hooks.follows = "";
    };
    # Temporary patcher until https://github.com/NixOS/nix/issues/3920 is resolved
    nixpkgs-patcher.url = "github:gepbird/nixpkgs-patcher";
    bcachefs-nixpkgs-patch-429126 = {
      url = "https://github.com/NixOS/nixpkgs/pull/429126.patch";
      flake = false;
    };
    hyprland = {
      url = "github:hyprwm/Hyprland?ref=refs/heads/main";
    };
    hyprshutdown = {
      url = "github:hyprwm/hyprshutdown";
      inputs = {
        nixpkgs.follows = "hyprland/nixpkgs";
        systems.follows = "hyprland/systems";
        aquamarine.follows = "hyprland/aquamarine";
        hyprgraphics.follows = "hyprland/hyprgraphics";
        hyprutils.follows = "hyprland/hyprutils";
      };
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      bcachefs-nixpkgs-patch-429126,
      disko,
      home-manager,
      hyprshutdown,
      lanzaboote,
      nix-index-database,
      nixos-hardware,
      nixpkgs-patcher,
      nixvim,
      nixvim-config,
      nur,
      plasma-manager,
      pre-commit-hooks,
      sops-nix,
      flake-parts,
      dms,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { config, ... }:
      {
        systems = [
          "x86_64-linux"
          # "aarch64-linux"
        ];
        imports = [
          flake-parts.flakeModules.modules
          pre-commit-hooks.flakeModule
          home-manager.flakeModules.home-manager
          ./modules
          ./nixosConfigs/workstation
        ];
        flake = {
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
                {
                  programs.nixvim.nixpkgs.useGlobalPackages = true;
                }
                config.flake.homeModules.mpv
                config.flake.homeModules.vaultwarden
                config.flake.homeModules.vesktop
                config.flake.homeModules.yt-dlp
                dms.homeModules.dankMaterialShell.default
              ];
              shared_modules = [
                config.flake.modules.nixos.plymouth
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
                lanzaboote.nixosModules.lanzaboote
                ./secure-boot.nix
                {
                  nixpkgs.overlays = [
                    (final: prev: {
                      hyprshutdown = hyprshutdown.packages.${final.stdenv.hostPlatform.system}.hyprshutdown;
                    })
                  ];
                }
              ];
              vladexa = {
                home-manager.users.vladexa = ./nixosConfigs/shared/home/vladexa.nix;
              };
            in
            {
              nixos = nixpkgs-patcher.lib.nixosSystem {
                specialArgs = inputs;
                nixpkgsPatcher.patches = pkgs: [ bcachefs-nixpkgs-patch-429126 ];
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
                  config.flake.modules.nixos.dolphin-overlay
                  config.flake.modules.nixos.gaming
                  config.flake.modules.nixos.workstation
                  config.flake.modules.nixos.workstation-hm
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
        };

        perSystem =
          { pkgs, config, ... }:
          {
            formatter = pkgs.nixfmt-tree;

            pre-commit.check.enable = true;
            pre-commit.settings =
              { pkgs, ... }:
              {
                hooks.nixfmt-rfc-style.enable = true;
                enabledPackages = with pkgs; [ sops ];
              };

            devShells.default = config.pre-commit.devShell;

            packages.nixos-options-doc =
              (pkgs.nixosOptionsDoc { inherit (config.flake.nixosConfigurations.workstation) options; })
              .optionsCommonMark;
          };
      }
    );
}

# vim: ts=2 sw=2 et:
