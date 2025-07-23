{
  programs.yt-dlp.config = {
    sponsorblock-remove = "sponsor";
    cookies-from-browser = "firefox";
    mark-watched = true;
    embed-metadata = true;
    embed-thumbnail = true;
    concurrent-fragments = 4;
  };
}
