{
  flake.modules.homeManager.matrix-client =
    { pkgs, ... }:
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

      home.packages = [ pkgs.fluffychat ];
    };
}
