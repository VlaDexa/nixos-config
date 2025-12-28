{ withSystem, config, ... }:
{
  flake.modules.nixos.dolphin-overlay.nixpkgs.overlays = [
    config.flake.overlays.dolphin-wrapped
  ];

  flake.overlays.dolphin-wrapped =
    final: prev:
    withSystem prev.stdenv.hostPlatform.system (
      { config, ... }:
      {
        kdePackages = prev.kdePackages.overrideScope (
          kfinal: kprev: {
            dolphin = config.packages.dolphin-wrapped;
          }
        );
      }
    );

  perSystem =
    { pkgs, ... }:
    {
      packages.dolphin-wrapped = pkgs.symlinkJoin {
        name = "dolphin-wrapped";
        paths = [ pkgs.kdePackages.dolphin ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/dolphin \
            --set XDG_CONFIG_DIRS "${pkgs.libsForQt5.kservice}/etc/xdg:$XDG_CONFIG_DIRS"
        '';
      };
    };
}
