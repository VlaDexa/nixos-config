{
  home-manager.users.vladexa =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ ./hyprland/home.nix ];

      home.packages = with pkgs; [
        mullvad-vpn
        qbittorrent

        libreoffice-fresh
      ];

      xdg.mimeApps.defaultApplicationPackages = [ pkgs.libreoffice-fresh ];

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

        obs-studio = {
          enable = true;
          plugins = with pkgs.obs-studio-plugins; [
            wlrobs
            obs-vkcapture
            obs-pipewire-audio-capture
          ];
        };

        chromium.extensions = [
          "ammjkodgmmoknidbanneddgankgfejfh" # 7TV
        ];
      };

      services = {
        easyeffects.enable = true;

        podman.enable = config.programs.distrobox.enable;
      };

      home.sessionVariables = {
        TERMINAL = lib.optionalString config.programs.kitty.enable "kitty";
      };
    };
}
