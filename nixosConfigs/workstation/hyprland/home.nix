{
  imports = [
    ./settings
    ./cliphist.nix
    ./waybar.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # NixOS
    # plugins = with pkgs.hyprlandPlugins; [
    #   hyprlock
    # ];
  };

  services.blueman-applet = {
    enable = true;
    systemdTargets = [ "hyprland-session.target" ];
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        width = 300;
        height = "(0, 300)";
        offset = "(30, 50)";
        origin = "top-right";
        transparency = 10;
        frame_color = "#eceff1";
        font = "Droid Sans 9";
      };

      urgency_normal = {
        background = "#37474f";
        foreground = "#eceff1";
        timeout = 10;
      };
    };
  };
  systemd.user.services.dunst.Unit.ConditionEnvironment = "XDG_CURRENT_DESKTOP=Hyprland";

  programs.wofi.enable = true;
}
