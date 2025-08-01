{ pkgs, ... }:
{
  home-manager.users.vladexa = {
    home.packages = with pkgs; [
      mullvad-vpn
      qbittorrent
    ];
    programs.yt-dlp.enable = true;
    services.easyeffects.enable = true;
    programs.vesktop.enable = true;

    services.podman.containers.sqlserver.autoStart = false;
  };
}
