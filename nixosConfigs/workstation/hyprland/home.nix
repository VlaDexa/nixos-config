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

  programs.wofi.enable = true;
}
