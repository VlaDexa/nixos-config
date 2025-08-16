{ pkgs, ... }:
{
  home-manager.users.vladexa = {
    home.packages = with pkgs; [
      mullvad-vpn
      qbittorrent
    ];
    programs = {
      yt-dlp.enable = true;

      vesktop.enable = true;

      distrobox = {
        enable = true;
        containers = {
          aur-archlinux = {
            image = "archlinux:latest";
            additional_packages = "git pacman-contrib base-devel";
          };
        };
      };
    };

    services.podman.containers.sqlserver.autoStart = false;
    services.easyeffects.enable = true;
  };
}
