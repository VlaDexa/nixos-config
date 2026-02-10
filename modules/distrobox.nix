{
  flake.modules.nixos.distrobox = {
    # Enable common container config files in /etc/containers
    virtualisation.containers.enable = true;
    virtualisation = {
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };
  };

  flake.modules.homeManager.distrobox =
    { osConfig, ... }:
    {
      services.podman.enable = osConfig.virtualisation.podman.enable;
      programs.distrobox = {
        enable = true;
        containers = {
          aur-archlinux = {
            image = "archlinux:latest";
            additional_packages = "git pacman-contrib base-devel";
          };
        };
      };
    };
}
