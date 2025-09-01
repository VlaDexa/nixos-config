{ config, ... }:
{
  sops.templates."arangodb.env".content = ''
    ARANGODB_PASSWORD=${config.sops.placeholder.arangodb_password}
  '';

  services.arangodb = {
    enable = true;
    password = "@ARANGODB_PASSWORD@";
    environmentFiles = [ config.sops.templates."arangodb.env".path ];
  };
}
