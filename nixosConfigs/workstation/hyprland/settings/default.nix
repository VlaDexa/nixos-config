{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./animations.nix
    ./binds.nix
    ./decorations.nix
    ./env.nix
    ./hyprcursor.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./input.nix
    ./monitors.nix
    ./windowrules.nix
  ];

  wayland.windowManager.hyprland.settings = {
    "$mainMod" = "SUPER";
    "$terminal" = lib.getExe pkgs.kitty;
    "$fileManager" = lib.getExe' pkgs.kdePackages.dolphin "dolphin";
    "$menu" = "${lib.getExe config.programs.wofi.package} --show drun";
    "$browser" = "${lib.getExe config.programs.chromium.finalPackage}";

    exec = [
      "${lib.getExe pkgs.runapp} -i background.slice ${lib.getExe' pkgs.kdePackages.kwallet "kwalletd6"}"
      "${lib.getExe' pkgs.glib "gsettings"} set org.gnome.desktop.interface Adwaita-dark"
      "${lib.getExe' pkgs.glib "gsettings"} set org.gnome.desktop.interface color-scheme prefer-dark"
    ];

    general = {
      gaps_in = 5;
      gaps_out = 5;

      border_size = 1;

      # https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors
      "col.active_border" = "rgb(00a3ff)";
      "col.inactive_border" = "rgb(8ab4f8)";

      # Set to true enable resizing windows by clicking and dragging on borders and gaps
      resize_on_border = false;

      # Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
      allow_tearing = false;

      layout = "dwindle";
    };
  };
}
