{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    cachix
    nixfmt-rfc-style

    gnupg
    tree
    file
    jq
    bat

    spotify

    wl-clipboard

    # Work
    teams-for-linux
    clickup
    devenv

    telegram-desktop
    fd
    ripgrep

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
    secrets.mssql_password = { };
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
    mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = "chromium-browser.desktop";
      };
    };
  };

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      extraPackages = with pkgs; [ gcc ];
    };

    plasma = {
      enable = true;
      overrideConfig = true;

      spectacle.shortcuts.captureRectangularRegion = "Meta+Shift+S";
      configFile = {
        kdeglobals.General = {
          BrowserApplication = {
            value = "chromium-browser.desktop";
            shellExpand = true;
          };
        };
        spectaclerc.General = {
          clipboardGroup = "PostScreenshotCopyImage";
        };
        plasmashellrc = lib.mkIf config.programs.yt-dlp.enable {
          Action_0 = {
            Automatic = true;
            Description = "Plays the youtube/twitch video";
            "Number of commands" = 1;
            Regexp = "^http.+(youtu|twitch)";
          };
          "Action_0\\/Command_0" = {
            Commandline = {
              value = "mpv --script-opts=ytdl_hook-try_ytdl_first=yes %s";
              shellExpand = true;
            };
            Description = "Opens mpv";
            Enabled = true;
            Icon = "mpv";
            Output = 0;
          };
          General = {
            "Number of Actions" = 1;
          };
          EditActionDialog = {
            ColumnState = {
              value = "AAAA/wAAAAAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgQAAAADAAEAAQAAAAAAAAAAAAAAAGT/////AAAAAQAAAAAAAAADAAAAZAAAAAEAAAAAAAAAZAAAAAEAAAAAAAABPAAAAAEAAAAAAAAD6AAAAABkAAAAAAAAAAAAAAAAAAAAAQ==";
              escapeValue = false;
            };
          };
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
      nativeMessagingHosts = with pkgs; [ firefoxpwa ];
      profiles.vladexa = {
        isDefault = true;
        search = {
          default = "ddg";
          force = true;
        };
        settings."extensions.autoDisableScopes" = 0;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          privacy-badger
          react-devtools
          bitwarden
          pwas-for-firefox
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
      # Stolen from https://wiki.cachyos.org/configuration/enabling_hardware_acceleration_in_google_chrome/
      commandLineArgs = [
        "--use-gl=angle"
        "--use-angle=vulkan"
        "--enable-features=Vulkan,VulkanFromANGLE,DefaultANGLEVulkan,AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoEncoder,VaapiIgnoreDriverChecks,UseMultiPlaneFormatForHardwareVideo"
      ];
    };

    fish.enable = true;

    kitty = {
      enable = true;
      settings = {
        shell = ''${pkgs.fish}/bin/fish'';
      };
      font = {
        package = pkgs.nerd-fonts.fira-code;
        name = "Fira Code";
      };
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
      ignores = [
        "devenv.yaml"
        "devenv.nix"
        "devenv.lock"
        ".devenv.flake.nix"
        ".devenv"
      ];
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

    mpv.enable = true;

    direnv.enable = true;
  };

  fonts.fontconfig.enable = true;

  services = {
    kdeconnect.enable = true;

    git-sync = {
      enable = true;
      repositories."nvim-config" = {
        path = "${config.xdg.configHome}/nvim";
        uri = "git@github.com:VlaDexa/nvim-config.git";
      };
    };
  };

  home.sessionVariables = {
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  home.stateVersion = "25.11";
}
