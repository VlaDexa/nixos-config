{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.hyprlock.enable = true;

  services.blueman.enable = true;

  security.pam.services.hyprland.kwallet.enable = true;

  environment.systemPackages = [ pkgs.kdePackages.kwallet ];
}
