{
  lib,
  pkgs,
  config,
  ...
}:
let
  bgutilVersion = "1.1.0";
in
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

    xdg.configFile."yt-dlp/plugins/bgutil-ytdlp-pot-provider".source = pkgs.fetchzip {
      pname = "bgutil-ytdlp-pot-provider";
      version = bgutilVersion;
      url = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider/releases/download/${bgutilVersion}/bgutil-ytdlp-pot-provider.zip";
      hash = "sha256-9PErBYSViEiIcfw2g3ZfiObPMM8tgOsH3Ue0zwlBYBQ=";
      stripRoot = false;
    };

    # TODO: run it natively like a normal human being
    services.podman = {
      enable = lib.mkForce true;
      containers.bgutil-ytdlp-pot-provider = {
        image = "docker.io/brainicism/bgutil-ytdlp-pot-provider:${bgutilVersion}";
        ports = [ "4416:4416" ];
      };
    };
  };
}
