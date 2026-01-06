{
  # https://wiki.hypr.land/Configuring/Variables/#decoration
  wayland.windowManager.hyprland.settings.decoration = {
    rounding = 12;
    # rounding_power = 2;

    # Change transparency of focused and unfocused windows
    active_opacity = 1.0;
    inactive_opacity = 1.0;

    shadow = {
      enabled = true;
      range = 30;
      render_power = 5;
      offset = "0 5";
      color = "rgba(00000070)";
    };

    # https://wiki.hypr.land/Configuring/Variables/#blur
    blur = {
      enabled = true;
      size = 3;
      passes = 1;

      vibrancy = 0.1696;
    };
  };
}
