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
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_testing;

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
      };
    };
  };

  services.mullvad-vpn = {
    enable = true;
    enableExcludeWrapper = false;
  };

  virtualisation.oci-containers.containers.sqlserver.autoStart = false;
}
