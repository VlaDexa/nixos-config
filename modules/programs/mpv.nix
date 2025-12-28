{
  flake.homeModules.mpv =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    let
      hasYtdlp = config.programs.yt-dlp.enable;
    in
    {
      config = {
        services.jellyfin-mpv-shim = {
          mpvConfig = {
            include = "~/.config/mpv/mpv.conf";
          };
          settings = {
            mpv_ext = true;
          };
        };

        programs.mpv = {
          defaultProfiles = [ "gpu-hq" ];
          config = {
            # Enables hardware decoding
            hwdec = "vulkan,vaapi,auto-safe,auto-copy";
            gpu-api = "vulkan";
            gpu-context = "waylandvk";
            # Prioritizes english audio over russian
            # But also, if no english audio is found, it will use russian
            alang = "en,eng,ru";
            # Selects the new video renderer
            vo = "gpu-next";
            # HDR videos
            target-colorspace-hint = true;
            target-colorspace-hint-mode = "source";
            # target-peak="300";
            # target-contrast="3000";
            save-position-on-quit = true;
            # By default mpv tries to use youtube-dl and then chooses yt-dlp
            # Saves some time by saying that it needs only yt-dlp
            script-opts = lib.mkIf hasYtdlp "ytdl_hook-ytdl_path=${config.programs.yt-dlp.package}/bin/yt-dlp";
            # Use better scaling algorithm by default
            scale = "ewa_lanczos4sharpest";
            scale-blur = "0.981251";
            # Perfect playback
            video-sync = "display-resample";
            # Apparently this improves quality of videos with lower than display refresh rates
            # https://github.com/mpv-player/mpv/wiki/Interpolation
            interpolation = true;
            tscale = "oversample";
            # Don't allow new windows be larger than the screen
            autofit-larger = "100%x100%";
            keepaspect-window = false;
            # Use more than 2 channels for audio
            #ao="alsa";
            #audio-channels="auto";
            # Better screenshots
            screenshot-jxl-distance = "0.1";
            screenshot-jxl-effort = "9";
            screenshot-webp-lossless = "yes";
            screenshot-webp-compression = "6";
            screenshot-format = "jxl";
            # Look for subs in some folders
            sub-auto = "fuzzy";
            sub-file-paths = "Subs:subs:Subtitles:subtitles";
          };
          profiles = {
            stream = {
              profile = "low-latency";
              cache = false;
            };
            music = {
              profile-cond = "path:find('[Mm]usic')";
              resume-playback = false;
              shuffle = true;
              video = false;
            };
          };

          package = pkgs.mpv-unwrapped.wrapper {
            scripts =
              with pkgs.mpvScripts;
              (
                [
                  mpris
                  thumbfast
                  modernz
                ]
                ++ lib.optionals hasYtdlp [ sponsorblock ]
              );

            mpv = pkgs.mpv-unwrapped.override {
              ffmpeg = pkgs.ffmpeg-full;
            };

            youtubeSupport = hasYtdlp;
          };
        };
      };
    };
}
