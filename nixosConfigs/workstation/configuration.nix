{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hyprland/system.nix
  ];
  system.stateVersion = "26.05";

  system.etc.overlay.enable = true;
  # services.userborn.enable = true;
  # system.nixos-init.enable = true; # Rust based init system or something

  networking.hostName = "workstation";

  networking = {
    networkmanager.enable = false;
    useNetworkd = true;
  };

  boot.plymouth.enable = true; # Doesn't work with bcachefs encryption

  # THP always is faster
  # https://www.phoronix.com/review/thp-madvise-always
  boot.kernel.sysfs = {
    kernel.mm.transparent_hugepage = {
      enabled = "always";
      defrag = "defer";
      shmem_enabled = "within_size";
    };
  };

  # Define a user account.
  users.users.vladexa = {
    isNormalUser = true;
    extraGroups = [
      "video"
      "docker"
      "wheel"
      "adbusers"
      "podman"
      config.security.tpm2.tssGroup
    ]; # Enable ‘sudo’ for the user.
    subUidRanges = [
      {
        count = 65534;
        startUid = 100001;
      }
    ];
    subGidRanges = [
      {
        count = 65534;
        startGid = 100001;
      }
    ];
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets.password.path;
  };
  users.users.root.initialHashedPassword = "";

  # For easyeffects
  programs.dconf.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # For josm's urban3d plugin
    stdenv.cc.cc
    pkgs.libGL
    pkgs.jogl
  ];
  programs.gpu-screen-recorder.enable = true;

  services.mullvad-vpn = {
    enable = true;
    enableExcludeWrapper = false;
  };

  # Add static location
  sops.secrets.workstation-location = {
    path = "/etc/geolocation";
    mode = "600";
    group = config.users.users.geoclue.group;
    owner = config.users.users.geoclue.name;
    restartUnits = [ "geoclue.service" ];
  };
  environment.etc."geoclue/conf.d/10-workstation-location.conf".text = lib.generators.toINI { } {
    static-source.enable = true;
  };
  systemd.services.geoclue.restartTriggers = [
    config.environment.etc."geoclue/conf.d/10-workstation-location.conf".source
  ];
  systemd.services.geoclue.after = [ "sops-nix.service" ];
  services.geoclue2 = {
    enable = true;
    enable3G = false;
    enableCDMA = false;
    enableModemGPS = false;
    enableNmea = false;
    enableWifi = false;
    # Can't enable because it requires to add location to store
    # enableStaticSource = true;
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

    jellyfin.user = "vladexa";
  };

  hardware = {
    amdgpu.overdrive.enable = true;
    amdgpu.zluda.enable = true;
    graphics.extraPackages = with pkgs; [
      amf
    ];
  };

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    abrmd.enable = true;
  };

  nixpkgs.config.chromium.enableWideVine = true;
}
