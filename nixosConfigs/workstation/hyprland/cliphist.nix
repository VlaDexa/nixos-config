{
  lib,
  config,
  pkgs,
  ...
}:
{
  services.cliphist = {
    enable = true;
    systemdTargets = "hyprland-session.target";
  };

  wayland.windowManager.hyprland.settings.bind =
    let
      cliphist = lib.getExe config.services.cliphist.package;
      mpv = lib.getExe config.programs.mpv.package;
      rg = lib.getExe pkgs.ripgrep;
      wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
      wofi = lib.getExe config.programs.wofi.package;
    in
    [
      "$mainMod, G, exec, ${cliphist} list | ${wofi} -d -k /dev/null | ${cliphist} decode | ${wl-copy}"
      "$mainMod, Y, exec, ${mpv} $(${cliphist} list | ${rg} --text 'http.+(youtu|twitch)' | ${wofi} -d -k /dev/null | ${cliphist} decode)"
    ];
}
