{
  config,
  lib,
  pkgs,
  options,
  ...
}:
{
  system.stateVersion = "25.11";

  networking = {
    hostName = "workstation";
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
    timeServers = options.networking.timeServers.default ++ [ "time.cloudflare.com" ];

    # DoH
    nameservers = [
      "127.0.0.1"
      "::1"
    ];
    networkmanager.dns = "none";
  };

  # Set your time zone.
  time.timeZone = "Europe/Ljubljana";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocales = [
    "ru_RU.UTF-8/UTF-8"
  ];
  i18n.extraLocaleSettings = {
    LC_TIME = "sl_SI.UTF-8";
    LC_MONETARY = "sl_SI.UTF-8";
    LC_NUMERIC = "sl_SI.UTF-8";
    LC_MESSAGES = "en_US.UTF-8";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = [ "bcachefs" ];

    plymouth = {
      enable = true; # Doesn't work with bcachefs encryption
      theme = "loader";
      themePackages = with pkgs; [
        (adi1090x-plymouth-themes.override {
          selected_themes = [ "loader" ];
        })
      ];
    };

    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
    loader.timeout = 0;
  };

  sops = {
    age.keyFile = "/var/lib/sops-nix/key.txt";
    defaultSopsFile = ../secrets.yaml;

    secrets.password.neededForUsers = true;
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.power-profiles-daemon.enable = true;

  services.geoclue2.enable = true;
  location.provider = "geoclue2";

  services.fwupd.enable = true;

  services.ananicy = {
    enable = true;
    rulesProvider = pkgs.ananicy-rules-cachyos;
    package = pkgs.ananicy-cpp;
  };

  programs.fish.enable = true;

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

  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
  };

  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      autoNumlock = true;
    };
    defaultSession = "plasma";
  };
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    kate
    oxygen
  ];

  # DoH
  services.dnscrypt-proxy2 = {
    enable = true;
    # Settings reference:
    # https://github.com/DNSCrypt/dnscrypt-proxy/blob/master/dnscrypt-proxy/example-dnscrypt-proxy.toml
    settings = {
      ipv6_servers = true;
      require_dnssec = true;
      # Add this to test if dnscrypt-proxy is actually used to resolve DNS requests
      # query_log.file = "/var/log/dnscrypt-proxy/query.log";
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };

      # You can choose a specific set of servers from https://github.com/DNSCrypt/dnscrypt-resolvers/blob/master/v3/public-resolvers.md
      server_names = [
        "cloudflare"
        "cloudflare-ipv6"
      ];
    };
  };

  # Open ports in the firewall.
  networking.firewall =
    let
      kdeconnectPortRange = {
        from = 1714;
        to = 1764;
      };
    in
    {
      allowedTCPPortRanges = [ kdeconnectPortRange ];
      allowedUDPPortRanges = [ kdeconnectPortRange ];
    };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  hardware.bluetooth.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
}
