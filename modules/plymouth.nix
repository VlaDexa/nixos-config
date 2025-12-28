{
  flake.modules.nixos.plymouth =
    { pkgs, ... }:
    {
      boot.plymouth = {
        theme = "loader";
        themePackages = with pkgs; [
          (adi1090x-plymouth-themes.override {
            selected_themes = [ "loader" ];
          })
        ];
      };
    };
}
