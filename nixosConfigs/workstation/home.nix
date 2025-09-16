{ pkgs, ... }:
{
  home-manager.users.vladexa = {
    imports = [ ./hyprland/home.nix ];
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

      chromium.extensions = [
        "ammjkodgmmoknidbanneddgankgfejfh" # 7TV
      ];
    };

    services = {
      easyeffects.enable = true;

      podman.enable = true;
    };
  };
}
