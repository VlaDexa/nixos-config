{
  lib,
  pkgs,
  config,
  ...
}:
{
  config = lib.mkIf config.programs.yt-dlp.enable {
    programs.yt-dlp.settings = {
      sponsorblock-remove = "sponsor";
      cookies-from-browser = "firefox";
      mark-watched = true;
      embed-metadata = true;
      embed-thumbnail = true;
      concurrent-fragments = 4;
    };

    xdg.configFile."yt-dlp/plugins/bgutil-ytdlp-pot-provider".source = pkgs.fetchzip rec {
      pname = "bgutil-ytdlp-pot-provider";
      version = "1.1.0";
      url = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases/download/${version}/bgutil-ytdlp-pot-provider.zip";
      hash = "sha256-dC4QT6g7re5bYlhwLFu5liu9VOTmAPC39NUK/8qE3DM=";
      stripRoot = false;
    };
  };
}
