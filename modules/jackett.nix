{
  flake.modules.nixos.jackett = {
    services.jackett.enable = true;
    services.flaresolverr.enable = true;
  };
}
