{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.hyprlock.enable = true;

  services.blueman.enable = true;

  services.dbus.packages = [ pkgs.kdePackages.kwallet ];
}
