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

  programs.wofi.enable = true;
}
