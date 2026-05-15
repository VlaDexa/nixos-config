{
  config,
  lib,
  pkgs,
  ...
}:
{
  wayland.windowManager.hyprland.settings =
    let
      runapp = lib.getExe pkgs.runapp;
      hyprshutdown = lib.getExe pkgs.hyprshutdown;
      playerctl = lib.getExe pkgs.playerctl;
      wpctl = lib.getExe' pkgs.wireplumber "wpctl";

      mainMod = "SUPER";
      terminal = lib.getExe pkgs.kitty;
      fileManager = lib.getExe' pkgs.kdePackages.dolphin "dolphin";
      browser = "${lib.getExe config.programs.chromium.finalPackage}";

      mkRaw = lib.generators.mkLuaInline;

      keys = keys: lib.concatStringsSep " + " keys;
      mkeys = akeys: keys ([ mainMod ] ++ akeys);
      mkey = key: mkeys [ key ];

      bind = args: { _args = args; };
      bindl = args: bind (args ++ [ { locked = true; } ]);
      bindel =
        args:
        bind (
          args
          ++ [
            {
              locked = true;
              repeat = true;
            }
          ]
        );
      bindm = args: bind (args ++ [ { mouse = true; } ]);

      exec = cmd: mkRaw "hl.dsp.exec_cmd(\"${cmd}\")";
      rexec = cmd: exec "${runapp} ${cmd}";
    in
    {
      bind = [
        (bind [
          (mkey "C")
          (mkRaw "hl.dsp.window.close()")
        ])
        # {
        #   _args = [
        #     (mkeys [ "J" ])
        #     (mkRaw "hl.dsp.layout(\"togglesplit\")")
        #   ];
        # }
        (bind [
          (mkey "M")
          (exec hyprshutdown)
        ])
        (bind [
          (mkey "P")
          (mkRaw "hl.dsp.window.pseudo()")
        ])
        (bind [
          (mkey "V")
          (mkRaw "hl.dsp.window.float({ action = \"toggle\" })")
        ])

        (bind [
          (mkey "B")
          (rexec browser)
        ])
        (bind [
          (mkey "E")
          (rexec fileManager)
        ])
        (bind [
          (mkey "Escape")
          (rexec (lib.getExe pkgs.mission-center))
        ])
        (bind [
          (mkey "Q")
          (rexec terminal)
        ])
        (bind [
          (mkey "S")
          (rexec (lib.getExe pkgs.pwvucontrol))
        ])

        # Move focus with mainMod + arrow keys
        (bind [
          (mkey "left")
          (mkRaw "hl.dsp.focus({direction = \"left\"})")
        ])
        (bind [
          (mkey "right")
          (mkRaw "hl.dsp.focus({direction = \"right\"})")
        ])
        (bind [
          (mkey "up")
          (mkRaw "hl.dsp.focus({direction = \"up\"})")
        ])
        (bind [
          (mkey "down")
          (mkRaw "hl.dsp.focus({direction = \"down\"})")
        ])
        # Nvim moves
        (bind [
          (mkey "h")
          (mkRaw "hl.dsp.focus({direction = \"left\"})")
        ])
        (bind [
          (mkey "l")
          (mkRaw "hl.dsp.focus({direction = \"right\"})")
        ])
        (bind [
          (mkey "k")
          (mkRaw "hl.dsp.focus({direction = \"up\"})")
        ])
        (bind [
          (mkey "j")
          (mkRaw "hl.dsp.focus({direction = \"down\"})")
        ])
      ]
      ++ (lib.flatten (
        map (
          i:
          let
            mod = a: b: a - (b * (a / b));
            key = toString (mod i 10);
            ws = toString i;
          in
          [
            # Switch workspaces with mainMod + [0-9]
            (bind [
              (mkey key)
              (mkRaw "hl.dsp.focus({ workspace = \"${ws}\" })")
            ])
            # Move active window to a workspace with mainMod + SHIFT + [0-9]
            (bind [
              (mkeys [
                "SHIFT"
                key
              ])
              (mkRaw "hl.dsp.window.move({ workspace = \"${ws}\" })")
            ])
          ]
        ) (lib.range 1 10)
      ))
      ++ [
        # Screenshots
        (bind [
          (mkeys [
            "SHIFT"
            "s"
          ])
          (exec "${lib.getExe pkgs.grimblast} -f copy area")
        ])
        # Move/resize windows with mainMod + LMB/RMB and dragging
        (bindm [
          (mkey "mouse:272")
          (mkRaw "hl.dsp.window.drag()")
        ])
        (bindm [
          (mkey "mouse:273")
          (mkRaw "hl.dsp.window.resize()")
        ])
        # Laptop multimedia keys for volume and LCD brightness (all bindel)
        # ",XF86AudioRaiseVolume, exec, ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        # ",XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        # ",XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
        (bindel [
          "XF86AudioMicMute"
          (exec "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle")
        ])
        # ",XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        # ",XF86MonBrightnessUp, exec, ${brightnessctl} -e4 -n2 set 5%+"
        # ",XF86MonBrightnessDown, exec, ${brightnessctl} -e4 -n2 set 5%-"

        (bindl [
          "XF86AudioNext"
          (exec "${playerctl} next")
        ])
        (bindl [
          "XF86AudioPause"
          (exec "${playerctl} play-pause")
        ])
        (bindl [
          "XF86AudioPlay"
          (exec "${playerctl} play-pause")
        ])
        (bindl [
          "XF86AudioPrev"
          (exec "${playerctl} previous")
        ])
      ];
    };
}
