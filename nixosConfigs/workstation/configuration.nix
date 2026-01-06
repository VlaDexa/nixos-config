{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./hyprland/system.nix
  ];
  system.stateVersion = "26.05";

  system.etc.overlay.enable = true;
  services.userborn.enable = true;
  system.nixos-init.enable = true; # Rust based init system or something

  networking.hostName = "workstation";

  networking = {
    networkmanager.enable = false;
    useNetworkd = true;
  };

  boot.plymouth.enable = true; # Doesn't work with bcachefs encryption
  boot.initrd.systemd.enable = true; # Systemd boot

  # THP always is faster
  # https://www.phoronix.com/review/thp-madvise-always
  boot.kernelParams = [ "transparent_hugepage=always" ];

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

  # For easyeffects
  programs.dconf.enable = true;
  programs.nix-ld.enable = true;

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

    lact.enable = true;

    peertube-runner = {
      # enable = true;
      instancesToRegister.vladexa = {
        url = "https://peertube.vladexa.xyz";
        runnerName = "workstation";
        registrationTokenFile = config.sops.secrets.peertube-runner-token.path;
      };
    };

    jellyfin = {
      enable = true;
      user = "vladexa";
    };
  };

  hardware = {
    amdgpu.overdrive.enable = true;
    graphics.extraPackages = [ pkgs.amf ];
  };

  nixpkgs.config.chromium.enableWideVine = true;
}
