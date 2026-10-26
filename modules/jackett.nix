{
  flake.modules.nixos.jackett =
    { lib, pkgs, ... }:
    let
      mkProxy = name: backendPort: {
        description = "Socket proxy for ${name}";
        requires = [
          "${name}.service"
          "${name}-proxy.socket"
        ];
        after = [
          "${name}.service"
          "${name}-proxy.socket"
        ];

        serviceConfig = {
          Type = "notify";
          TimeoutStartSec = "180s";

          # Wait for the backend to begin listening.
          ExecStartPre = pkgs.writeShellScript "wait-for-${name}" ''
            for ((i = 0; i < 120; i++)); do
              if ${lib.getExe pkgs.netcat-openbsd} -z -w 1 127.0.0.1 ${toString backendPort}; then
                exit 0
              fi
              ${lib.getExe' pkgs.coreutils "sleep"} 1
            done
            exit 1
          '';

          ExecStart =
            "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd "
            + "--exit-idle-time=5min 127.0.0.1:${toString backendPort}";
        };
      };
    in
    {
      services.jackett = {
        enable = true;
        port = 19117;
        openFirewall = false;
      };

      services.flaresolverr = {
        enable = true;
        port = 18191;
        openFirewall = false;
      };

      systemd.services = {
        jackett = {
          wantedBy = lib.mkForce [ ];
          unitConfig.StopWhenUnneeded = true;
        };

        flaresolverr = {
          wantedBy = lib.mkForce [ ];
          unitConfig.StopWhenUnneeded = true;
          environment.HOST = "127.0.0.1";
        };

        jackett-proxy = mkProxy "jackett" 19117;
        flaresolverr-proxy = mkProxy "flaresolverr" 18191;
      };

      systemd.sockets = {
        jackett-proxy = {
          wantedBy = [ "sockets.target" ];
          listenStreams = [ "127.0.0.1:9117" ];
        };

        flaresolverr-proxy = {
          wantedBy = [ "sockets.target" ];
          listenStreams = [ "127.0.0.1:8191" ];
        };
      };
    };
}
