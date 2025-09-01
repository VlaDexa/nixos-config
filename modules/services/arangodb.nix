{
  config,
  lib,
  pkgs,
  my-nur,
  ...
}:
let
  cfg = config.services.arangodb;
  user = config.users.users.arangodb.name;
  group = config.users.groups.arangodb.name;
in
{
  options.services.arangodb = {
    enable = lib.mkEnableOption "ArangoDb";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8529;
      description = "TCP port number for receiving TLS connections.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the firewall port(s).";
    };

    databaseDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/arangodb3/";
      description = "The path to the database directory.";
    };

    appsDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/arangodb3-apps/";
      description = "The directory for Foxx applications.";
    };

    logFile = lib.mkOption {
      type = lib.types.path;
      default = "/var/log/arangodb3/arangod.log";
      description = "Log destination.";
    };

    package = lib.mkPackageOption my-nur.packages.${pkgs.stdenv.hostPlatform.system} "arangodb" { };
  };

  config = lib.mkIf cfg.enable {
    users.users.arangodb = {
      inherit group;
      isSystemUser = true;
    };
    users.groups.arangodb = { };

    systemd.services.arangodb = {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        User = user;
        Group = group;
        Environment = [
          "ICU_DATA=${cfg.package}/share/arangodb3"
          "TZ_DATA=${cfg.package}/share/arangodb3/tzdata"
        ];
        ExecStart =
          let
            format = pkgs.formats.ini { };
            arangd-conf = format.generate "arangod.conf" {
              database = {
                directory = cfg.databaseDir;
                password = "RootPassword";
              };

              server = {
                endpoint = "tcp://0.0.0.0:${toString cfg.port}";
                storage-engine = "auto";
              };

              javascript = {
                startup-directory = "${cfg.package}/share/arangodb3/js";
                app-path = cfg.appsDir;
              };

              log = {
                level = "info";
                file = cfg.logFile;
              };
            };
          in
          "${cfg.package}/bin/arangod --configuration ${arangd-conf}";
        StateDirectory =
          let
            statePath = "/var/lib/";
          in
          lib.optional (lib.hasPrefix statePath cfg.databaseDir) (lib.removePrefix statePath cfg.databaseDir)
          ++ lib.optional (lib.hasPrefix statePath cfg.appsDir) (lib.removePrefix statePath cfg.appsDir);
        LogsDirectory =
          let
            logPath = "/var/log";
          in
          lib.optional (lib.hasPrefix logPath cfg.appsDir) (lib.removePrefix logPath (dirOf cfg.logFile));
      };
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;
  };
}
