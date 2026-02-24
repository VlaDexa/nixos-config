{
  config,
  hyprland,
  lib,
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      grimblast = prev.grimblast.override { hyprland = config.programs.hyprland.package; };
    })
  ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # set the flake package
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # make sure to also set the portal package, so that they are in sync
    portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    withUWSM = false; # Broken
  };

  qt = {
    enable = true;
    style = "adwaita-dark";
    platformTheme = "qt5ct";
  };

  systemd.services.display-manager.environment.XDG_CURRENT_DESKTOP =
    lib.mkIf config.services.displayManager.ly.enable "X-NIXOS-SYSTEMD-AWARE";

  xdg.portal.config.common.default = "hyprland";

  programs.hyprlock.enable = true;

  services.blueman.enable = true;

  security.pam.services."vladexa".kwallet.enable = true;
  services.dbus.packages = [ pkgs.kdePackages.kwallet ];
}
