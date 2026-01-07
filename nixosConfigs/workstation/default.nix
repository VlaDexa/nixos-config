{
  imports = [
    ./home.nix
    ./twitch.nix
    ./hyprland/dms.nix
  ];

  flake.modules.nixos.workstation.imports = [
    ./configuration.nix
    ./hardware-configuration.nix
    ./disk-configs
  ];
}
