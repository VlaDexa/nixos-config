{ moduleWithSystem, ... }:
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
      hyprlandConf = hyprland.settings;
      mkIfHyprland = lib.mkIf hyprlandEnabled;
    in
    {
      programs.dankMaterialShell =
        let
          hyprshutdown = lib.getExe pkgs.hyprshutdown;
        in
        {
          enable = true;
          systemd.enable = true;
          systemd.restartIfChanged = true;
          enableVPN = false; # Fuck Network Manager
          default.settings = {
            showWorkspaceIndex = true;
            showWorkspaceApps = true;
            # Disable builtin wallpapers
            screenPreferences.wallpaper = [ ];

            customPowerActionReboot = "${hyprshutdown} -p reboot";
            customPowerActionPowerOff = "${hyprshutdown} -p shutdown now";
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
        in
        {
          bind = [
            "$mainMod, G, exec, ${dmsexe} ipc call clipboard toggle"
            "$mainMod, R, exec, ${dmsexe} ipc call spotlight toggle"
          ];
          bindl = [
            # Audio Controls
            ", XF86AudioMute, exec, ${dmsexe} ipc call audio mute"
          ];
          bindel = [
            ", XF86AudioRaiseVolume, exec, ${dmsexe} ipc call audio increment 3"
            ", XF86AudioLowerVolume, exec, ${dmsexe} ipc call audio decrement 3"
            # Brightness Controls
            ", XF86MonBrightnessUp, exec, ${dmsexe} ipc call brightness increment 5"
            ", XF86MonBrightnessDown, exec, ${dmsexe} ipc call brightness decrement 5"
          ];
        };
    }
  );
}
