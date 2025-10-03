{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  qt = {
    enable = true;
    style = "adwaita-dark";
    platformTheme = "qt5ct";
  };

  xdg.portal.config.common.default = "hyprland";

  programs.hyprlock.enable = true;

  services.blueman.enable = true;

  security.pam.services.hyprland.kwallet.enable = true;
  services.dbus.packages = [ pkgs.kdePackages.kwallet ];
}
