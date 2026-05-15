{ moduleWithSystem, inputs, ... }:
{
  flake.modules.homeManager.dankMaterialShell = moduleWithSystem (
    { inputs', ... }:
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      hyprland = config.wayland.windowManager.hyprland;
      hyprlandEnabled = hyprland.enable;
      hyprlandConf = hyprland.settings.config;
      mkIfHyprland = lib.mkIf hyprlandEnabled;
    in
    {
      imports = [
        inputs.dms.homeModules.dank-material-shell
      ];

      programs.dank-material-shell =
        let
          hyprshutdown = lib.getExe pkgs.hyprshutdown;
        in
        {
          enable = true;
          systemd.enable = true;
          systemd.restartIfChanged = true;
          enableVPN = false; # Fuck Network Manager
          settings = {
            currentThemeName = "blue";
            currentThemeCategory = "generic";
            showWorkspaceIndex = true;
            showWorkspaceApps = true;
            # Disable builtin wallpapers
            screenPreferences.wallpaper = [ ];

            customPowerActionReboot = "${hyprshutdown} -p reboot";
            customPowerActionPowerOff = "${hyprshutdown} -p 'shutdown now'";
            customPowerActionLogout = "${hyprshutdown}";

            weatherLocation = "Maribor";
            weatherCoordinates = "46.5576439,15.6455854";
            useAutoLocation = false;
            weatherEnabled = true;
            barConfigs = [
              {
                # Default shit
                id = "default";
                name = "Main Bar";
                enabled = true;
                position = 0;
                screenPreferences = [
                  "all"
                ];
                showOnLastDisplay = true;
                leftWidgets = [
                  "launcherButton"
                  "workspaceSwitcher"
                  "focusedWindow"
                ];
                centerWidgets = [
                  "music"
                  "clock"
                  "weather"
                ];
                rightWidgets = [
                  "systemTray"
                  "clipboard"
                  "cpuUsage"
                  "memUsage"
                  "notificationButton"
                  "battery"
                  "controlCenterButton"
                ];
                spacing = 4;
                innerPadding = 4;
                bottomGap = 0;
                transparency = 1;
                widgetTransparency = 1;
                squareCorners = false;
                noBackground = false;
                gothCornersEnabled = false;
                gothCornerRadiusOverride = false;
                gothCornerRadiusValue = 12;
                widgetOutlineEnabled = false;
                widgetOutlineColor = "primary";
                widgetOutlineOpacity = 1;
                widgetOutlineThickness = 1;
                fontScale = 1;
                autoHide = false;
                autoHideDelay = 250;
                openOnOverview = false;
                visible = true;
                popupGapsAuto = true;
                popupGapsManual = 4;
                maximizeDetection = true;
                # Custom shit
                borderColor = "secondary";
                borderEnabled = true;
                borderOpacity = 1;
                borderThickness = mkIfHyprland hyprlandConf.general.border_size;
              }
            ];
            launchPrefix = lib.getExe pkgs.runapp;
          };
        };

      wayland.windowManager.hyprland.settings =
        let
          dmsexe = lib.getExe (inputs'.dms.packages.default);

          # Cancer
          mainMod = "SUPER";
          mkRaw = lib.generators.mkLuaInline;
          keys = keys: lib.concatStringsSep " + " keys;
          key = key: keys [ key ];
          mkeys = akeys: keys ([ mainMod ] ++ akeys);
          mkey = key: mkeys [ key ];

          exec = cmd: mkRaw "hl.dsp.exec_cmd(\"${cmd}\")";
          dmsexec = args: exec "${dmsexe} ${args}";
          bind = args: { _args = args; };
          bindl = args: bind (args ++ [ { locked = true; } ]);
          bindel =
            args:
            bind (
              args
              ++ [
                {
                  locked = true;
                  repeat = true;
                }
              ]
            );
        in
        {
          bind = [
            (bind [
              (mkey "G")
              (dmsexec "ipc call clipboard toggle")
            ])
            (bind [
              (mkey "R")
              (dmsexec "ipc call spotlight toggle")
            ])

            # Audio Controls
            (bindl [
              (key "XF86AudioMute")
              (dmsexec "ipc call audio mute")
            ])
            (bindel [
              (key "XF86AudioRaiseVolume")
              (dmsexec "ipc call audio increment 3")
            ])
            (bindel [
              (key "XF86AudioLowerVolume")
              (dmsexec "ipc call audio decrement 3")
            ])

            # Brightness Controls
            (bindel [
              (key "XF86MonBrightnessUp")
              (dmsexec "ipc call brightness increment 5")
            ])
            (bindel [
              (key "XF86MonBrightnessDown")
              (dmsexec "ipc call brightness decrement 5")
            ])
          ];
        };
    }
  );
}
