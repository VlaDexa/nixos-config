{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}:
let
  defaultMimePackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.gwenview
    kdePackages.okular
    kdePackages.ark
    zoom-us
  ];
in
{
  home.packages =
    with pkgs;
    [
      hydra-check
      cachix
      nixfmt-rfc-style

      gnupg
      tree
      file
      jq
      bat
      killall

      spotify

      wl-clipboard

      devenv

      telegram-desktop
      fd
      ripgrep

      # Spellcheck
      hunspell
      hunspellDicts.ru_RU
      hunspellDicts.en_US
    ]
    ++ defaultMimePackages
    ++ lib.optionals osConfig.services.desktopManager.plasma6.enable [
      # KDE Virtual Desktop
      kdePackages.krfb
      kdePackages.krdc

      #KDE Theme
      nur.repos.shadowrz.klassy-qt6
    ];

  sops = {
    age.keyFile = "/var/lib/sops-nix/key.txt";

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
    selfMail = {
      address = "vgrechannik@mail.ru";
      realName = "Vladislav Grechannik";
      thunderbird = {
        enable = true;
        profiles = [ "personal" ];
      };
    };
    edu = {
      flavor = "outlook.office365.com";
      address = "vladislav.grechannik@almamater.si";
      realName = "Vladislav Grechannik";
      thunderbird = {
        enable = true;
        profiles = [ "personal" ];
        settings = id: {
          "mail.server.server_${id}.authMethod" = 10;
          "mail.smtpserver.smtp_${id}.authMethod" = 10;
        };
      };
    };
  };

  xdg = {
    enable = true;
    mimeApps = {
      enable = true;
      defaultApplicationPackages =
        lib.optional config.programs.nixvim.enable config.programs.nixvim.package
        ++ lib.optional config.programs.mpv.enable config.programs.mpv.package
        ++ [ pkgs.kdePackages.dolphin ]
        ++ defaultMimePackages
        ++ lib.optional config.programs.chromium.enable config.programs.chromium.package
        ++ lib.optional config.programs.kitty.enable config.programs.kitty.package;
    };
  };

  programs = {
    nixvim = {
      enable = true;
      defaultEditor = true;
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
        options = [ "compose:ralt" ];
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
            { digitalClock.time.showSeconds = "always"; }
            "org.kde.plasma.showdesktop"
          ];
        }
      ];
    };

    firefox = {
      enable = true;
      profiles.vladexa = {
        isDefault = true;
        search = {
          default = "ddg";
          force = true;
        };
        settings."extensions.autoDisableScopes" = 0;
        extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
          bitwarden
          indie-wiki-buddy
          privacy-badger
          react-devtools
          sponsorblock
          # ublock-origin
          adnauseam
        ];
      };
      languagePacks = [
        "en-US"
        "ru"
        "sl"
      ];
    };

    chromium = {
      enable = true;
      extensions = [
        "fkagelmloambgokoeokbpihmgpkbgbfm" # Indie Wiki Buddy
        "kcpfnbjlimolkcjllfooaipdpdjmjigg" # Linkumori
        "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
        "fmkadmapgofadopljbjfkapdkoienihi" # React DevTools
        "anmmhkomejbdklkhoiloeaehppaffmdf" # React Scan
        "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
        "kdbmhfkmnlmbkgbabkdealhhbfhlmmon" # SteamDB
        "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
      ];
      dictionaries = with pkgs; [
        hunspellDictsChromium.en_US
      ];
      commandLineArgs = [
        "--enable-features=VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL"
        "--ozone-platform=wayland"
      ];
    };

    fish.enable = true;

    kitty = {
      enable = true;
      settings.shell = lib.getExe pkgs.fish;
      font = {
        package = pkgs.nerd-fonts.fira-code;
        name = "Fira Code";
      };
      keybindings = {
        "kitty_mod+t" = "new_tab_with_cwd";
      };
      enableGitIntegration = true;
    };

    thunderbird = {
      enable = true;
      profiles = {
        personal = {
          isDefault = true;
        };
      };
    };

    git = {
      enable = true;
      settings = {
        user = {
          name = "Vladislav Grechannik";
          email = "vgrechannik@gmail.com";
        };
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
        ".pre-commit-config.yaml"
        ".direnv/"
      ];
    };

    gh = {
      enable = true;
      settings.git_protocol = "ssh";
      hosts."github.com".user = "VlaDexa";
    };

    ssh = {
      enable = true;
      matchBlocks."*".compression = true;
    };

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 3";
      };
      flake = "github:VlaDexa/nixos-config";
    };

    bitwarden = {
      enable = true;

      selfHostedUrl = "https://vaultwarden.vladexa.xyz";
      email = "vgrechannik@gmail.com";
    };

    command-not-found.enable = false;
    nix-index.enable = true;

    mpv.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  fonts.fontconfig.enable = true;

  services.kdeconnect.enable = true;

  home.sessionVariables = {
    SSH_ASKPASS_REQUIRE = "prefer";
  };

  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';

  home.stateVersion = "25.11";
}
