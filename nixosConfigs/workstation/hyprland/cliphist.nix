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
      wofi = lib.getExe config.programs.wofi.package;
      runapp = lib.getExe pkgs.runapp;

      mainMod = "SUPER";

      mkRaw = lib.generators.mkLuaInline;

      keys = keys: lib.concatStringsSep " + " keys;
      mkeys = akeys: keys ([ mainMod ] ++ akeys);
      mkey = key: mkeys [ key ];

      bind = args: { _args = args; };

      exec = cmd: mkRaw "hl.dsp.exec_cmd(\"${cmd}\")";
      rexec = cmd: exec "${runapp} ${cmd}";
    in
    [
      # "$mainMod, G, exec, ${cliphist} list | ${wofi} -d -k /dev/null | ${cliphist} decode | ${wl-copy}"
      (bind [
        (mkey "Y")
        (rexec "${mpv} --no-terminal $(${cliphist} list | ${rg} --text 'http.+(youtu|twitch)' | ${wofi} -d -k /dev/null | ${cliphist} decode)")
      ])
    ];
}
