{
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "immediate, fullscreen:1"
      "immediate, fullscreen:2"
    ];
    windowrule = [
      "suppressevent maximize, class:.*"
      "immediate, class:^(mpv)$"

      # Float Steam
      "float, class:steam"
      "center, class:steam, title:Steam"
      "opacity 1 1, class:steam"
      "size 1100 700, class:steam, title:Steam"
      "size 460 800, class:steam, title:Friends List"
      "idleinhibit fullscreen, class:steam"

      # Define terminal tag to style them uniformly
      "tag +terminal, class:(Alacritty|kitty|com.mitchellh.ghostty)"
    ];
  };
}
