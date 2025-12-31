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

      programs.chromium.extensions = [
        "ammjkodgmmoknidbanneddgankgfejfh" # 7TV
      ];

      programs.firefox.profiles.vladexa.extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        seventv
      ];

      home.packages = with pkgs; [ chatterino7 ];
    };
}
