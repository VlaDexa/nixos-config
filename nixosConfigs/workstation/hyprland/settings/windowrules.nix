{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      {
        name = "Terminal Rules";
        tag = "+terminal";
        "match:class" = "(Alacritty|kitty|com\\.mitchellh\\.ghostty)";
      }
      {
        name = "Steam Friends List";
        float = "true";
        size = "460 800";
        "match:class" = "steam";
        "match:title" = "Friends List";
      }
      {
        name = "Steam Rules";
        "match:class" = "steam";
        idle_inhibit = "fullscreen";
      }
      {
        # Ignore maximize requests from all apps. You'll probably like this.
        name = "suppress-maximize-events";
        "match:class" = ".*";

        suppress_event = "maximize";
      }
      {
        name = "DMS floating default";
        float = "true";
        "match:class" = "^(org.quickshell)$";
      }
      # "match:class mpv, immediate yes"
    ];
  };
}
