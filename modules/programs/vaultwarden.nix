{
  flake.homeModules.vaultwarden =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      cfg = config.programs.bitwarden;
    in
    {
      options.programs.bitwarden = {
        enable = lib.mkEnableOption "Bitwarden";

        enableExtensions = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Should install Bitwarden browser extensions";
        };

        selfHostedUrl = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          example = "https://vw.example.com";
          description = "Self-hosted Bitwarden server URL.";
        };

        email = lib.mkOption {
          type = lib.types.str;
          example = "you@example.com";
          description = "The email address for your bitwarden account.";
        };

        enableRbw = lib.mkOption {
          default = true;
          example = false;
          description = "Whether to enable rbw.";
          type = lib.types.bool;
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [ pkgs.bitwarden-desktop ];

        programs.chromium.extensions = lib.mkIf cfg.enableExtensions [ "nngceckbapebfimnlniiiahkandclblb" ];
        # programs.firefox.extensions.packages = lib.mkIf cfg.enableExtensions [
        #   pkgs.nur.repos.rycee.firefox-addons.bitwarden
        # ];

        programs.rbw = {
          enable = cfg.enableRbw;
          settings = {
            base_url = cfg.selfHostedUrl;
            email = cfg.email;
            pinentry = pkgs.pinentry-qt;
          };
        };
      };
    };
}
