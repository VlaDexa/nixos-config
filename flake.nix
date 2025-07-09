{
  inputs = {
    nixpkgs.url = "flake:nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko/latest";
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
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
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
    }:
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nur.modules.nixos.default
            ./configuration.nix
            ./hardware-configuration.nix
            ./cachix.nix
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-ssd
            nixos-hardware.nixosModules.common-hidpi
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-cpu-amd-pstate
            nixos-hardware.nixosModules.common-cpu-amd-zenpower
            nixos-hardware.nixosModules.common-gpu-amd
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [
                plasma-manager.homeManagerModules.plasma-manager
                ./modules/programs/bitwarden-desktop.nix
              ];
              home-manager.backupFileExtension = "backup";

              # This should point to your home.nix path of course. For an example
              # of this see ./home.nix in this directory.
              home-manager.users.vladexa = ./home/vladexa.nix;
            }
            disko.nixosModules.disko
            ./disko-config.nix
            sops-nix.nixosModules.sops
          ];
        };

        vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./disko-config.nix
            disko.nixosModules.disko
            (
              {
                config,
                lib,
                pkgs,
                ...
              }:
              {
                system.stateVersion = "25.11";

                boot = {
                  kernelParams = [ "console=ttyS0" ];
                  supportedFilesystems = [ "bcachefs" ];
                  loader = {
                    systemd-boot.enable = true;
                    efi.canTouchEfiVariables = true;
                  };
                };

                users.users.vladexa = {
                  initialPassword = "yeahvmpass";
                  isNormalUser = true;
                  shell = pkgs.zsh;
                  extraGroups = [ "wheel" ];
                };

                programs.zsh.enable = true;

                disko.imageBuilder.imageFormat = "qcow2";
                disko.devices.disk.main.imageSize = "50G";
                disko.devices.bcachefs_filesystems.main_bcachefs.passwordFile = lib.mkForce null;
              }
            )
          ];
        };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
