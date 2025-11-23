{
  home-manager.users.vladexa =
    {
      config,
      lib,
      pkgs,
      osConfig,
      ...
    }:
    {
      imports = [ ./hyprland/home.nix ];

      home.packages = with pkgs; [
        mullvad-vpn
        qbittorrent

        libreoffice-fresh

        kdePackages.kimageformats # For jxl support in Gwenview
      ];

      xdg.mimeApps.defaultApplicationPackages = [ pkgs.libreoffice-fresh ];

      programs = {
        chromium.extensions = [
          "ammjkodgmmoknidbanneddgankgfejfh" # 7TV
        ];

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
            obs-pipewire-audio-capture
            obs-vkcapture
            wlrobs
          ];
        };

        vesktop.enable = true;

        yt-dlp.enable = true;

        lutris = {
          enable = true;
          steamPackage = osConfig.programs.steam.package;
          protonPackages = [ pkgs.proton-ge-bin ];
          defaultWinePackage = pkgs.proton-ge-bin;
        };
      };

      services = {
        easyeffects.enable = false && osConfig.programs.dconf.enable;

        podman.enable = config.programs.distrobox.enable;
      };

      home.sessionVariables = {
        OBS_VKCAPTURE = 1;
        PROTON_ENABLE_HDR = 1;
        PROTON_ENABLE_WAYLAND = 1;

        TERMINAL = lib.optionalString config.programs.kitty.enable "kitty";
      };
    };
}
