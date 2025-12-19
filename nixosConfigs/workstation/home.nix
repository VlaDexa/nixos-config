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
      imports = [
        ./hyprland/home.nix
        ./twitch.nix
      ];

      home.packages = with pkgs; [
        mullvad-vpn
        qbittorrent

        libreoffice-fresh

        kdePackages.kimageformats # For jxl support in Gwenview
        runapp
      ];

      xdg.mimeApps.defaultApplicationPackages = [ pkgs.libreoffice-fresh ];

      programs = {
        chromium.extensions = [
          "ammjkodgmmoknidbanneddgankgfejfh" # 7TV
          "dnhpnfgdlenaccegplpojghhmaamnnfp" # Augmented Steam
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

        element-desktop.enable = true;
      };

      services = {
        easyeffects.enable = true && osConfig.programs.dconf.enable;

        podman.enable = config.programs.distrobox.enable;
        jellyfin-mpv-shim.enable = true;
      };

      systemd.user.services.steam = {
        Unit = rec {
          After = [
            "network-online.target"
            "graphical-session.target"
          ];
          Wants = After;
          Description = "Open Steam in the background at boot";
        };
        Service = {
          ExecStart = "${lib.getExe osConfig.programs.steam.package} -nochatui -nofriendsui -silent %U";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      home.sessionVariables = {
        OBS_VKCAPTURE = 1;
        PROTON_ENABLE_HDR = 1;
        PROTON_ENABLE_WAYLAND = 1;

        TERMINAL = lib.optionalString config.programs.kitty.enable "kitty";
      };
    };
}
