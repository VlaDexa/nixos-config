{
  config,
  lib,
  pkgs,
  options,
  ...
}:
{
  system.stateVersion = "25.11";

  networking.hostName = "workstation";

  boot.plymouth.enable = true; # Doesn't work with bcachefs encryption

  # Define a user account.
  users.users.vladexa = {
    isNormalUser = true;
    extraGroups = [
      "video"
      "docker"
      "wheel"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets.password.path;
  };
  users.users.root.initialHashedPassword = "";

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    package = pkgs.steam.override {
      extraEnv = {
        PROTON_ENABLE_WAYLAND = true;
        PROTON_ENABLE_HDR = true;
        SDL_DYNAMIC_API = "${pkgs.SDL2}/lib/libSDL2-2.0.so";
      };
    };
  };
  # For easyeffects
  programs.dconf.enable = true;

  services.mullvad-vpn = {
    enable = true;
    enableExcludeWrapper = false;
  };
}
