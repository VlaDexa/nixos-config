{
  pkgs,
  options,
  ...
}:
{
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = [ "bcachefs" ];

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

  networking = {
    networkmanager.enable = true; # Easiest to use and most distros use this by default.
    timeServers = options.networking.timeServers.default ++ [ "time.cloudflare.com" ];

    # DoH
    nameservers = [
      "127.0.0.1"
      "::1"
    ];
    networkmanager.dns = "none";

    # Open ports in the firewall.
    firewall =
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

  sops = {
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets.password.neededForUsers = true;
  };

  location.provider = "geoclue2";
  # List services that you want to enable:
  services = {
    geoclue2.enable = true;

    # Enable sound.
    # hardware.pulseaudio.enable = true;
    # OR
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    fwupd.enable = true;

    ananicy = {
      enable = true;
      rulesProvider = pkgs.ananicy-rules-cachyos;
      package = pkgs.ananicy-cpp;
    };

    power-profiles-daemon.enable = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;

    # DoH
    dnscrypt-proxy2 = {
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
          "quad9-doh-ip4-port443-filter-ecs-pri"
          "quad9-doh-ip6-port443-filter-ecs-pri"
          "cloudflare"
          "cloudflare-ipv6"
          "google"
          "google-ipv6"
        ];
      };
    };

    desktopManager.plasma6.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        autoNumlock = true;
        theme = "sddm-astronaut-theme";
      };
      defaultSession = "plasma";
    };

    arangodb = {
      enable = true;
    };
  };

  xdg.icons.fallbackCursorThemes = [ "breeze_cursors" ];

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    kate
    oxygen
  ];

  programs = {
    fish.enable = true;

    ssh = {
      startAgent = true;
      enableAskPassword = true;
      extraConfig = ''
        Host vpn.vladexa.xyz
            Port 5555
        Host ssh-vps.vladexa.xyz
            ProxyCommand ${pkgs.cloudflared}/bin/cloudflared access ssh --hostname %h
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    curlHTTP3
    git
    kdePackages.sddm-kcm
    sddm-astronaut
    kdePackages.qtmultimedia
  ];

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  hardware.bluetooth.enable = true;

  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    channel.enable = false;
  };
  nixpkgs.config.allowUnfree = true;

  nix.registry.nixpkgs = {
    from = {
      id = "nixpkgs";
      type = "indirect";
    };
    to = {
      owner = "NixOS";
      repo = "nixpkgs";
      type = "github";
      ref = "nixos-unstable";
    };
  };
}
