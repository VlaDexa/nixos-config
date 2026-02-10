{ config, ... }:
let
  flakeConfig = config;
in
{
  flake.modules.nixos.workstation-hm = {
    imports = with flakeConfig.flake.modules; [ nixos.distrobox ];

    home-manager.users.vladexa =
      {
        config,
        lib,
        pkgs,
        osConfig,
        ...
      }:
      {
        imports = with flakeConfig.flake.modules; [
          ./hyprland/home.nix
          homeManager.dankMaterialShell
          homeManager.distrobox
          homeManager.gaming
          homeManager.matrix-client
          homeManager.twitch
        ];

        home.packages = with pkgs; [
          mullvad-vpn
          qbittorrent
          android-tools

          libreoffice-fresh

          kdePackages.kimageformats # For jxl support in Gwenview
          ffmpeg-full
          runapp
        ];

        xdg.mimeApps.defaultApplicationPackages = [ pkgs.libreoffice-fresh ];

        programs = {
          chromium.extensions = [
            "dnhpnfgdlenaccegplpojghhmaamnnfp" # Augmented Steam
            "ijcpiojgefnkmcadacmacogglhjdjphj" # Shinigami Eyes
          ];

          firefox.profiles.vladexa.extensions.packages = [
            pkgs.nur.repos.rycee.firefox-addons.shinigami-eyes
          ];

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
        };

        services = {
          easyeffects.enable = true && osConfig.programs.dconf.enable;

          jellyfin-mpv-shim.enable = true;
        };

        home.sessionVariables = {
          OBS_VKCAPTURE = 1;
          PROTON_ENABLE_HDR = 1;
          PROTON_ENABLE_WAYLAND = 1;

          TERMINAL = lib.optionalString config.programs.kitty.enable "kitty";
        };
      };
  };
}
