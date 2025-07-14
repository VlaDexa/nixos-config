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

    gh

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
      rev = "fd38c09ebc656c46d9b4fd4ad848192934a45586";
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
          BrowserApplication = "chromium.desktop";
        };
        spectaclerc.General = {
          clipboardGroup = "PostScreenshotCopyImage";
        };
        kxkbrc.Layout = {
          DisplayNames = ",";
          LayoutDefaultGlobal = 1;
          LayoutList = "us,ru";
          Options = "compose:ralt";
          ResetOldOptions = true;
          Use = true;
          VariantList = ",";
        };
      };
      session.sessionRestore.restoreOpenApplicationsOnLogin = "whenSessionWasManuallySaved";

      shortcuts = {
        "services/kitty.desktop" = {
          "_launch" = "Ctrl+Alt+T";
        };
        "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Alt+Shift,Switch to Next Keyboard Layout";
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
                  "applications:org.kde.systemsettings.desktop"
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

    firefox.enable = true;
    chromium = {
      enable = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm"
        "fmkadmapgofadopljbjfkapdkoienihi"
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
        format = "ssh";
        signByDefault = true;
      };
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

    command-not-found.enable = true;
  };

  services = {
    kdeconnect.enable = true;
  };

  home.sessionVariables = {
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  home.stateVersion = "24.11";
}
