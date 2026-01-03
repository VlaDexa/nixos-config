{ pkgs, ... }:
{
  home.pointerCursor.enable = true;
  home.pointerCursor.hyprcursor.enable = true;
  home.pointerCursor.gtk.enable = true;
  home.pointerCursor.x11.enable = true;
  home.pointerCursor.package = pkgs.rose-pine-hyprcursor;
  home.pointerCursor.name = "rose-pine-hyprcursor";
}
