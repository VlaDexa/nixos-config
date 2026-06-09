{ inputs, ... }:
{
  flake.modules.nixos.bore =
    { lib, config, ... }:
    let
      firstArrayed = xs: [
        (lib.elemAt xs 0)
      ];
    in
    {
      boot.kernelPatches = firstArrayed (
        [ ]
        ++ (lib.optional (lib.versionAtLeast config.boot.kernelPackages.kernel.version "7.1") {
          name = "bore-scheduler";
          patch = "${inputs.bore-scheduler}/patches/stable/linux-7.1-bore/0001-linux7.1-rc1-bore-6.6.3.patch";
          structuredExtraConfig.SCHED_BORE = lib.kernel.yes;
        })
        ++ (lib.optional (lib.versionAtLeast config.boot.kernelPackages.kernel.version "7.0") {
          name = "bore-scheduler";
          patch = "${inputs.bore-scheduler}/patches/stable/linux-7.0-bore/0001-linux7.0-rc2-bore-6.6.3.patch";
          structuredExtraConfig.SCHED_BORE = lib.kernel.yes;
        })
        ++ (lib.optionals (lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.18.22") [
          {
            name = "bore-scheduler";
            patch = "${inputs.bore-scheduler}/patches/stable/linux-6.18-bore/0001-linux6.18.22-bore-6.6.3.patch";
            structuredExtraConfig.SCHED_BORE = lib.kernel.yes;
          }
          {
            name = "prefer-prevcpu";
            patch = "${inputs.bore-scheduler}/patches/stable/linux-6.18-bore/1000-prefer-prevcpu-for-wakeup-v7.patch.txt";
          }
        ])
        ++ (lib.optionals (lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.6.107") [
          {
            name = "bore-scheduler";
            patch = "${inputs.bore-scheduler}/patches/stable/linux-6.6-bore/0001-linux6.6.107-bore5.9.6.patch";
            structuredExtraConfig.SCHED_BORE = lib.kernel.yes;
          }
          {
            name = "full-idle-smt";
            patch = "${inputs.bore-scheduler}/patches/stable/linux-6.6-bore/0002-sched-fair-Prefer-full-idle-SMT-cores-by-Andrea-Righ.patch";
          }
        ])
        ++ [ ]
      );

      # Works worse with BORE
      services.ananicy.enable = lib.mkForce false;
    };
}
