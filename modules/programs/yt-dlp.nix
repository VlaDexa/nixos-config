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

    xdg.configFile."yt-dlp/plugins/bgutil-ytdlp-pot-provider".source =
      pkgs.nur.repos.vladexa.bgutil-ytdlp-pot-provider.plugin;

    systemd.user.services.bgutil-ytdlp-pot-provider-server = {
      Unit = {
        After = [ "network-online.target" ];
        Description = pkgs.nur.repos.vladexa.bgutil-ytdlp-pot-provider.server.meta.description;
      };
      Service = {
        ExecStart = lib.getExe (
          pkgs.nur.repos.vladexa.bgutil-ytdlp-pot-provider.server.override { withBun = true; }
        );
        NoNewPrivileges = true;
        NonBlocking = true;
        PrivateDevices = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        Restart = "always";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        PartOf = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
