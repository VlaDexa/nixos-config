{ config, ... }:
{
  # imports = [ ./rusticl.nix ];

  flake.modules.nixos.davinci =
    {
      pkgs,
      ...
    }:
    {
      imports = [ config.flake.modules.nixos.rusticl ];

      environment.systemPackages = with pkgs; [
        davinci-resolve
      ];
    };
}
