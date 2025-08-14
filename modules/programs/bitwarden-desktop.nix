{
  lib,
  pkgs,
  config,
  ...
}:

let
  cfg = config.programs.bitwarden-desktop;
in
{
  options.programs.bitwarden-desktop = {
    enable = lib.mkEnableOption "Bitwarden Desktop";

    enableExtensions = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Should install Bitwarden browser extensions";
    };

    selfHostedUrl = lib.mkOption {
      type = lib.nullOr lib.types.str;
      example = "https://vw.example.com";
      description = "Self-hosted Bitwarden server URL.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.bitwarden-desktop ];

    programs.chromium.extensions = lib.mkIf cfg.enableExtensions [ "nngceckbapebfimnlniiiahkandclblb" ];
    programs.firefox.extensions.packages = lib.mkIf cfg.enableExtensions [
      pkgs.nur.repos.rycee.firefox-addons.bitwarden
    ];
  };
}
