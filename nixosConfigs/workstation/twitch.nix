{
  flake.modules.homeManager.twitch =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      programs.streamlink = {
        enable = true;
        settings = {
          player = lib.getExe config.programs.mpv.package;
          player-args = "--profile=stream";
          player-no-close = true;
        };
      };

      home.packages = with pkgs; [ chatterino7 ];
    };
}
