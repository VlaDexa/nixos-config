{
  flake.homeModules.vesktop.config = {
    programs.vesktop = {
      settings = {
        arRPC = true;
        hardwareVideoAcceleration = true;
        hardwareAcceleration = true;
      };
      vencord = {
        # useSystem = true;
        settings = {
          plugins = {
            FakeNitro.enabled = true;
          };
        };
      };
    };
  };
}
