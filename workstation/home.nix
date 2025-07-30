{ pkgs, ... }:
{
  home-manager.users.vladexa = {
    home.packages = with pkgs; [
      mullvad-vpn
      qbittorrent
    ];
    programs.yt-dlp.enable = true;
    services.podman.containers.sqlserver.autoStart = false;
  };
}
