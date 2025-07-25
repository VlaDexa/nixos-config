{ config, ... }:
{
  virtualisation.oci-containers.backend = "podman";
  virtualisation.oci-containers.containers = {
    sqlserver = {
      image = "mcr.microsoft.com/mssql/server:2025-latest";
      autoStart = true;
      ports = [ "1433:1433" ];
      environment = {
        ACCEPT_EULA = "Y";
      };
      environmentFiles = [
        config.sops.templates."sql-password.env".path
      ];
    };
  };
}
