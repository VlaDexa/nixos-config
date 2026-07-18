{
  flake.modules.homeManager.images = { pkgs, ... }: {
    home.packages = with pkgs; [
      digikam
      darktable
      hdrmerge
    ];
  };
}
