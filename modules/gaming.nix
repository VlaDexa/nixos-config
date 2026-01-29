{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        extraCompatPackages = with pkgs; [
          proton-ge-bin
        ];
        protontricks.enable = true;
      };
    };

  flake.modules.homeManager.gaming =
    {
      osConfig,
      pkgs,
      lib,
      config,
      ...
    }:
    {
      programs.lutris = {
        enable = true;
        steamPackage = osConfig.programs.steam.package;
        protonPackages = [ pkgs.proton-ge-bin ];
        defaultWinePackage = pkgs.proton-ge-bin;
      };

      systemd.user.services.steam = {
        Unit = rec {
          After = [
            "network-online.target"
            config.wayland.systemd.target
          ];
          Wants = After;
          Description = "Open Steam in the background at boot";
        };
        Service = {
          Type = "exec";
          ExecStart = "${lib.getExe osConfig.programs.steam.package} -nochatui -nofriendsui -silent %U";
          Restart = "on-failure";
          RestartSec = "5s";
        };
        Install.WantedBy = [ config.wayland.systemd.target ];
      };

      home.packages = with pkgs; [
        heroic
        gamescope
        gamemode
      ];
    };
}
