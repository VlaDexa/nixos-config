{ pkgs, lib, ... }:
{
  wayland.windowManager.hyprland.settings =
    let
      runapp = lib.getExe pkgs.runapp;
    in
    {
      bind = [
        "$mainMod, C, killactive,"
        "$mainMod, J, togglesplit, # dwindle"
        "$mainMod, M, exit,"
        "$mainMod, P, pseudo, # dwindle"
        "$mainMod, V, togglefloating,"

        "$mainMod, B, exec, ${runapp} $browser"
        "$mainMod, E, exec, ${runapp} $fileManager"
        "$mainMod, Escape, exec, ${runapp} ${lib.getExe pkgs.mission-center}"
        "$mainMod, Q, exec, ${runapp} $terminal"
        "$mainMod, R, exec, $menu"
        "$mainMod, S, exec, ${runapp} ${lib.getExe pkgs.pavucontrol}"

        # Move focus with mainMod + arrow keys
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        # Nvim moves
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"
        # Switch workspaces with mainMod + [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        # Screenshots
        "SUPER SHIFT, s, exec, ${runapp} ${lib.getExe pkgs.grimblast} -f copy area"
      ];
      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
      # Laptop multimedia keys for volume and LCD brightness
      bindel =
        let
          wpctl = lib.getExe' pkgs.wireplumber "wpctl";
          brightnessctl = lib.getExe pkgs.brightnessctl;
        in
        [
          ",XF86AudioRaiseVolume, exec, ${wpctl} set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          ",XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ",XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
          ",XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ",XF86MonBrightnessUp, exec, ${brightnessctl} -e4 -n2 set 5%+"
          ",XF86MonBrightnessDown, exec, ${brightnessctl} -e4 -n2 set 5%-"
        ];
      bindl =
        let
          playerctl = lib.getExe pkgs.playerctl;
        in
        [
          ", XF86AudioNext, exec, ${playerctl} next"
          ", XF86AudioPause, exec, ${playerctl} play-pause"
          ", XF86AudioPlay, exec, ${playerctl} play-pause"
          ", XF86AudioPrev, exec, ${playerctl} previous"
        ];
    };
}
