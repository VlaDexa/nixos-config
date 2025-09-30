{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ ./hyprland/system.nix ];
  system.stateVersion = "25.11";

  sops.secrets = {
    private-key = { };
    preshared-key = { };
  };
  networking.hostName = "workstation";
  networking.wg-quick.interfaces.wg0 = {
    address = [
      "172.30.0.8/32"
      "2a01:4f9:c012:cb73:ac1e::8/128"
    ];
    dns = [ "1.1.1.1" ];
    privateKeyFile = config.sops.secrets.private-key.path;
    autostart = false;

    peers = [
      {
        publicKey = "EbVAcKd4I2bUh+vggZEAvi4Mft09a08e58v7VrDYCDo=";
        presharedKeyFile = config.sops.secrets.preshared-key.path;
        allowedIPs = [
          "49.13.8.220"
        ];
        endpoint = "officevpn.solved-hub.com:51820";
        persistentKeepalive = 15;
      }
    ];
  };

  boot.plymouth.enable = true; # Doesn't work with bcachefs encryption
  # boot.initrd.systemd.enable = true; # Systemd boot

  # Define a user account.
  users.users.vladexa = {
    isNormalUser = true;
    extraGroups = [
      "video"
      "docker"
      "wheel"
      "adbusers"
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
  # For easyeffects
  programs.dconf.enable = true;

  programs.adb.enable = true;

  services.mullvad-vpn = {
    enable = true;
    enableExcludeWrapper = false;
  };

  # Disable all the plasma stuff
  services = {
    desktopManager.plasma6.enable = false;
    displayManager.defaultSession = "hyprland";
    displayManager.ly = {
      enable = true;
      x11Support = false;
      settings = {
        animation = "colormix";
        bigclock = "en";
        bigclock_seconds = true;
        numlock = true;
      };
    };

    displayManager.sddm.enable = false;
  };

  nixpkgs.config.chromium.enableWideVine = true;
}
