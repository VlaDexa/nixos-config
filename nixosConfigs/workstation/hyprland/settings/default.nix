{
  config,
  lib,
  pkgs,
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

  systemd.user.services.kwalletd = {
    Unit.Description = "KDE Wallet Daemon";
    Service = {
      Type = "exec";
      ExecStart = lib.getExe' pkgs.kdePackages.kwallet "kwalletd6";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ config.wayland.systemd.target ];
  };

  wayland.windowManager.hyprland.configType = "lua";
  wayland.windowManager.hyprland.settings = {
    on._args =
      let
        execs = [
          "${lib.getExe' pkgs.glib "gsettings"} set org.gnome.desktop.interface Adwaita-dark"
          "${lib.getExe' pkgs.glib "gsettings"} set org.gnome.desktop.interface color-scheme prefer-dark"
        ];
        tabbed = map (s: "\thl.dsp.exec_cmd(\"${s}\")") execs;
        lines = lib.concatStringsSep "\n" tabbed;
      in
      [
        "hyprland.start"
        (lib.generators.mkLuaInline "function()\n${lines}\nend")
      ];

    config.general = {
      gaps_in = 5;
      gaps_out = 5;

      border_size = 1;

      # https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors
      col.active_border = "rgba(00a3ffee)";
      col.inactive_border = "rgba(8ab4f8aa)";

      # Set to true enable resizing windows by clicking and dragging on borders and gaps
      resize_on_border = false;

      # Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
      allow_tearing = false;

      layout = "dwindle";
    };

    config.render = {
      direct_scanout = 1;
      non_shader_cm = 2;
      cm_auto_hdr = 0;
    };
  };
}
