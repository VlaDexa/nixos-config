{
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "immediate, fullscreen:1"
      "immediate, fullscreen:2"
    ];
    windowrule = [
      "suppressevent maximize, class:.*"
      "immediate, class:^(mpv)$"

      # Please Don't Float Steam
      "float, class:steam, title: Friends List"
      "center, class:steam, title:Steam"
      "opacity 1 1, class:steam"
      "size 460 800, class:steam, title:Friends List"
      "idleinhibit fullscreen, class:steam"

      # Define terminal tag to style them uniformly
      "tag +terminal, class:(Alacritty|kitty|com.mitchellh.ghostty)"
    ];
  };
}
