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
    { osConfig, pkgs, ... }:
    {
      programs.lutris = {
        enable = true;
        steamPackage = osConfig.programs.steam.package;
        protonPackages = [ pkgs.proton-ge-bin ];
        defaultWinePackage = pkgs.proton-ge-bin;
      };

      home.packages = with pkgs; [ heroic ];
    };
}
