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
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      nixosConfigurations =
        let
          nixpkgs-patched = import ./shared/nixpkgs-patched.nix { inherit nixpkgs self; };
          shared_home_modules = [
            plasma-manager.homeManagerModules.plasma-manager
            sops-nix.homeManagerModules.sops
            nix-index-database.homeModules.nix-index
            ./modules/containers/sql-server.nix
          ]
          ++ (builtins.attrValues (import ./modules/programs));
          shared_modules = [
            nur.modules.nixos.default
            home-manager.nixosModules.home-manager
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            ./cachix.nix
            lanzaboote.nixosModules.lanzaboote
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = shared_home_modules;
              home-manager.backupFileExtension = "backup";
            }
            ./shared/configuration.nix
            ./modules/plymouth.nix
            ./secure-boot.nix
          ];
          vladexa = {
            home-manager.users.vladexa = ./home/vladexa.nix;
          };
        in
        {
          nixos = nixpkgs-patched.lib.nixosSystem {
            modules =
              shared_modules
              ++ [
                nixos-hardware.nixosModules.common-pc-laptop
                nixos-hardware.nixosModules.common-pc-ssd
                nixos-hardware.nixosModules.common-hidpi
                nixos-hardware.nixosModules.common-cpu-amd
                nixos-hardware.nixosModules.common-cpu-amd-pstate
                nixos-hardware.nixosModules.common-cpu-amd-zenpower
                nixos-hardware.nixosModules.common-gpu-amd
                vladexa
              ]
              ++ builtins.attrValues (import ./laptop);
          };

          workstation = nixpkgs-patched.lib.nixosSystem {
            modules =
              shared_modules
              ++ [
                nixos-hardware.nixosModules.common-cpu-amd
                nixos-hardware.nixosModules.common-cpu-amd-pstate
                nixos-hardware.nixosModules.common-cpu-amd-zenpower
                nixos-hardware.nixosModules.common-gpu-amd
                nixos-hardware.nixosModules.common-hidpi
                nixos-hardware.nixosModules.common-pc-ssd
                vladexa
              ]
              ++ builtins.attrValues (import ./workstation);
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
    };
}

# vim: ts=2 sw=2 et:
