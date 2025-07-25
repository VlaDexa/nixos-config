{ pkgs, ... }:
{
  home-manager.users.vladexa = {
    home.packages = with pkgs; [ mullvad-vpn ];
    programs.yt-dlp.enable = true;
  };
}
