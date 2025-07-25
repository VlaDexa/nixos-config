{
  hardware-configuration = import ./hardware-configuration.nix;
  configuration = import ./configuration.nix;
  home = import ./home.nix;
}
// import ./disk-configs
