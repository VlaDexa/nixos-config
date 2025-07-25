{
  hardware-configuration = import ./hardware-configuration.nix;
  configuration = import ./configuration.nix;
  disk-config = import ./disk-config.nix;
}
