{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    cachix
    nixfmt-rfc-style

    gnupg
    tree
    file
    jq
    bat

    mpv

    spotify

    wl-clipboard

    # Work
    teams-for-linux
    clickup
    sqlcmd

    telegram-desktop
    fd
    ripgrep

    # Webdev
    nodePackages_latest.nodejs
    pnpm
    bun

    # Rust
    cargo

    # KDE Virtual Desktop
    kdePackages.krfb
    kdePackages.krdc

    #KDE Theme
    nur.repos.shadowrz.klassy-qt6

    # Spellcheck
    hunspell
    hunspellDicts.ru_RU
    hunspellDicts.en_US
  ];

  sops = {
    age.keyFile = "/var/lib/sops-nix/key.txt";
    defaultSopsFile = ../secrets.yaml;

    secrets.ssh_key = { };
  };

  accounts.email.accounts = {
    selfGmail = {
      flavor = "gmail.com";
      address = "vgrechannik@gmail.com";
      realName = "Vladislav Grechannik";
      primary = true;
      thunderbird = {
        enable = true;
        profiles = [ "personal" ];
      };
    };
    work = {
      flavor = "outlook.office365.com";
      address = "vladislav.grechannik@solved-hub.com";
      realName = "Vladislav Grechannik";
      thunderbird = {
        enable = true;
        profiles = [ "work" ];
      };
    };
  };

  xdg = {
    enable = true;
    configFile.nvim.source = builtins.fetchGit {
      url = "https://github.com/VlaDexa/nvim-config.git";
      rev = "6d0e00d5999efc8048daa339604ae452885427af";
    };
    mimeApps.enable = true;
  };

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };

    plasma = {
      enable = true;

      spectacle.shortcuts.captureRectangularRegion = "Meta+Shift+S";
      configFile = {
        kdeglobals.General = {
          "BrowserApplication[$e]" = "chromium.desktop";
        };
        spectaclerc.General = {
          clipboardGroup = "PostScreenshotCopyImage";
        };
      };

      input.keyboard = {
        layouts = [
          { layout = "us"; }
          { layout = "ru"; }
        ];
        numlockOnStartup = "on";
        options = [
          "compose:ralt"
        ];
      };

      session.sessionRestore.restoreOpenApplicationsOnLogin = "whenSessionWasManuallySaved";

      shortcuts = {
        "services/kitty.desktop" = {
          "_launch" = "Ctrl+Alt+T";
        };
        "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Alt+Shift";
      };

      workspace = {
        theme = "default";
        colorScheme = "KlassyDark";
        windowDecorations = {
          library = "org.kde.klassy";
          theme = "Klassy";
        };
      };

      panels = [
        {
          location = "bottom";
          widgets = [
            "org.kde.plasma.kickoff"
            "org.kde.plasma.pager"
            {
              iconTasks = {
                launchers = [
                  "applications:systemsettings.desktop"
                  "applications:org.kde.dolphin.desktop"
                  "preferred://browser"
                ];
              };
            }
            "org.kde.plasma.marginsseparator"
            "org.kde.plasma.systemtray"
            {
              name = "org.kde.plasma.weather";
              config = {
                WeatherStation.source = "bbcukmet|weather|Maribor, Slovenia, SI|3195506";
                Units = {
                  pressureUnit = 5008;
                  speedUnit = 9000;
                  temperatureUnit = 6001;
                  visibilityUnit = 2007;
                };
              };
            }
            {
              digitalClock.time.showSeconds = "always";
            }
            "org.kde.plasma.showdesktop"
          ];
        }
      ];
    };

    firefox = {
      enable = true;
      profiles.vladexa = {
        isDefault = true;
        search.default = "ddg";
        settings."extensions.autoDisableScopes" = 0;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          privacy-badger
          react-devtools
          bitwarden
        ];
      };
    };

    chromium = {
      enable = true;
      extensions = [
        "ddkjiahejlhfcafbddmgiahcphecmpfh"
        "fmkadmapgofadopljbjfkapdkoienihi"
        "mnjggcdmjocbbbhaepdhchncahnbgone"
      ];
      dictionaries = with pkgs; [
        hunspellDictsChromium.en_US
      ];
    };

    fish.enable = true;

    kitty = {
      enable = true;
      settings = {
        shell = ''${pkgs.fish}/bin/fish'';
      };
      # shellIntegration.enableFishIntegration = true;
    };

    thunderbird = {
      enable = true;
      profiles = {
        work = {
          isDefault = true;
        };
        personal = { };
      };
    };

    git = {
      enable = true;
      userName = "Vladislav Grechannik";
      userEmail = "vgrechannik@gmail.com";
      extraConfig = {
        rerere.enabled = true;
      };
      signing = {
        key = config.sops.secrets.ssh_key.path;
        format = "ssh";
        signByDefault = true;
      };
    };

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
      hosts."github.com".user = "VlaDexa";
    };

    ssh = {
      compression = true;
    };

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 3";
      };
      flake = "github:VlaDexa/nixos-config";
    };

    bitwarden-desktop = {
      enable = true;

      selfHostedUrl = "http://vpn.vladexa.xyz:6060";
    };

    rbw = {
      enable = true;
      settings = {
        base_url = "http://vpn.vladexa.xyz:6060";
        email = "vgrechannik@gmail.com";
        pinentry = pkgs.pinentry-qt;
      };
    };

    command-not-found.enable = false;
    nix-index.enable = true;
  };

  services = {
    kdeconnect.enable = true;
  };

  home.sessionVariables = {
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  home.stateVersion = "25.11";
}
