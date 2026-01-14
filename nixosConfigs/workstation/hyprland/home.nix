{
  imports = [
    ./settings
    ./cliphist.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null; # NixOS
    portalPackage = null;
    # plugins = with pkgs.hyprlandPlugins; [
    #   hyprlock
    # ];
  };
  wayland.systemd.target = "hyprland-session.target";

  programs.wofi.enable = true;
}
