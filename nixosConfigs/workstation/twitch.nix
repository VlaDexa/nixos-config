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
          version = oldAttrs.version + "-gifs";
          src = pkgs.fetchFromGitHub {
            owner = "VlaDexa";
            repo = "chatterino7";
            rev = "4616ae284ddc3e27e1ead16dd2cf3d6bf851f8fb";
            hash = "sha256-+BZo2ZZ3hfrarN+3oIcsiTa/NtO87c2n/klGx8zIa2w=";
            fetchSubmodules = true;
            leaveDotGit = true;
            postFetch = ''
              git -C $out rev-parse --short HEAD > $out/GIT_HASH
              find "$out" -name .git -print0 | xargs -0 rm -rf
            '';
          };
        }))
      ];
    };
}
