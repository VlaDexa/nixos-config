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
      hash = "sha256-e9e4f3afc56fe8e774950ee4f863f7767480b64819f358c7d536fad241fd5359=";
    };
  };
}
