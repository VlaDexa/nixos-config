{
  flake.modules.homeManager.twitch =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      programs.streamlink = {
        enable = true;
        settings = {
          player = lib.getExe config.programs.mpv.package;
          player-args = "--profile=stream";
          player-no-close = true;
        };
      };

      programs.chromium.extensions = [
        "lppmekppnliemjclknbagdhoocikieoi" # 7TV
      ];

      programs.firefox.profiles.vladexa.extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        seventv
      ];

      home.packages = with pkgs; [
        (chatterino7.overrideAttrs (oldAttrs: {
          version = "unstable-2026-09-27";
          src = oldAttrs.src.overrideAttrs {
            rev = "932e8991b6785cc70bef5e58309c31ab3023a148";
            hash = "sha256-RFUfjJn4HSEhYGD5sXMU88dMnP5xpowBJF+SQLcWzCk=";
          };
        }))
      ];
    };
}
