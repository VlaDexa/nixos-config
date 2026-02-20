{
  flake.modules.homeManager.matrix-client =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      programs.element-desktop = {
        enable = true;
        settings.features = {
          feature_use_device_session_member_events = true;
          feature_video_rooms = true;
          feature_group_calls = true;
          feature_element_call_video_rooms = true;
        };
      };

      systemd.user.services.gomuks-web = {
        Install.WantedBy = [ config.wayland.systemd.target ];
        Service = {
          ExecStart = lib.getExe' pkgs.gomuks-web "gomuks-web";
          Restart = "on-failure";
          RestartSec = "5s";
          Type = "exec";
        };
        Unit.Description = pkgs.gomuks-web.meta.description;
      };

      home.packages = [ pkgs.fluffychat ];
    };
}
