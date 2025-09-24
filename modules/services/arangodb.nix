{
  config,
  lib,
  pkgs,
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

    password = lib.mkOption {
      type = lib.types.str;
      description = "The initial password of the root user. Can be an [environment variable as parameter](https://docs.arangodb.com/3.12/operations/administration/configuration/#environment-variables-as-parameters). Warning: this string will be world-readable in /nix/store.";
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Files containing extra environment variables.";
    };

    enableUnixSocket = lib.mkEnableOption "Listen on a unix socket `/run/arangodb/arangodb.sock`.";

    package = lib.mkPackageOption pkgs.nur.repos.vladexa "arangodb" { };

    exitIdleTime = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = null;
      description = "Number of seconds the server will wait in idle state before shutting down.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.arangodb = {
      inherit group;
      isSystemUser = true;
    };
    users.groups.arangodb = { };

    systemd =
      let
        systemdSocket = "/run/arangodb/systemd.sock";
      in
      {
        sockets.proxy-to-arangodb = {
          socketConfig.ListenStream = [
            cfg.port
            "/run/arangodb/arangodb.sock"
          ];

          wantedBy = [ "sockets.target" ];
        };

        services.proxy-to-arangodb = {
          unitConfig = {
            Requires = [
              "arangodb.service"
              "proxy-to-arangodb.socket"
              # "proxy-to-arangodb.path"
            ];
            After = [
              "arangodb.service"
              "proxy-to-arangodb.socket"
              # "proxy-to-arangodb.path"
            ];
          };

          serviceConfig =
            let
              exitIdleTime = lib.optionalString (
                cfg.exitIdleTime != null
              ) "--exit-idle-time=${toString cfg.exitIdleTime}";
            in
            {
              Type = "notify";
              ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd ${exitIdleTime} ${systemdSocket}";
              PrivateTmp = true;
              PrivateNetwork = true;
              Restart = "on-failure";
              RestartSec = 5;
              AssertPathExists = [ systemdSocket ];
            };
        };

        # paths.proxy-to-arangodb = {
        #   pathConfig.PathExists = [ systemdSocket ];
        #
        #   wantedBy = [ "multi-user.target" ];
        # };
        #
        services.arangodb =
          let
            pidFile = "/run/arangodb/arangod.pid";
          in
          {
            after = [ "network.target" ];
            # wantedBy = [ "multi-user.target" ];
            unitConfig.StopWhenUnneeded = true;
            serviceConfig = {
              User = user;
              Group = group;
              Environment = [
                "ICU_DATA=${cfg.package}/share/arangodb3"
                "TZ_DATA=${cfg.package}/share/arangodb3/tzdata"
              ];
              EnvironmentFile = cfg.environmentFiles;
              ExecStart =
                let
                  format = pkgs.formats.ini { listsAsDuplicateKeys = true; };
                  arangd-conf = format.generate "arangod.conf" {
                    database = {
                      directory = cfg.databaseDir;
                      password = cfg.password;
                    };

                    server = {
                      # endpoint = [
                      #   "tcp://0.0.0.0:${toString cfg.port}"
                      # ]
                      # ++ lib.optional cfg.enableUnixSocket "unix:///run/arangodb/arangodb.sock";
                      endpoint = "unix://${systemdSocket}";
                      storage-engine = "auto";
                    };

                    javascript = {
                      startup-directory = "${cfg.package}/share/arangodb3/js";
                      app-path = cfg.appsDir;
                    };

                    log = {
                      level = "info";
                      file = cfg.logFile;
                      foreground-tty = true;
                    };
                  };
                in
                "${cfg.package}/bin/arangod --configuration ${arangd-conf} --pid-file ${pidFile}";
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
              RuntimeDirectory = lib.optional cfg.enableUnixSocket "arangodb";
              PIDFile = pidFile;
              Restart = "on-failure";
              RestartSec = 5;
            };
          };
      };

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.port;
  };
}
