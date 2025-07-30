{ config, lib, ... }:
{
  sops.templates."sql-password.env".content = ''
    MSSQL_SA_PASSWORD=${config.sops.placeholder.mssql_password}
  '';

  services.podman = {
    enable = lib.mkForce true;
    containers.sqlserver = {
      image = "mcr.microsoft.com/mssql/server:2025-latest";
      ports = [ "1433:1433" ];
      environment = {
        ACCEPT_EULA = "Y";
      };
      environmentFile = [
        config.sops.templates."sql-password.env".path
      ];
    };
  };
}
