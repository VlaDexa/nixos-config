{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
      # Only used during lanzaboote development
      inputs.pre-commit-hooks-nix.follows = "";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
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
      flake-utils,
      lanzaboote,
    }:
    {
      nixosConfigurations =
        let
          nixpkgs-patched = import ./shared/nixpkgs-patched.nix { inherit nixpkgs self; };
          shared_home_modules = [
            plasma-manager.homeManagerModules.plasma-manager
            sops-nix.homeManagerModules.sops
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
                ./secure-boot.nix
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
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      formatter = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    });
}

# vim: ts=2 sw=2 et:
