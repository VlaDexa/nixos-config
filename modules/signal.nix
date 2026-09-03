{
  flake.modules.homeManager.signal = { pkgs, lib, ... }: {
    home.packages = with pkgs; [
      signal-cli
      signal-desktop
    ];

    systemd.user = {
      timers.signal-cli-receive = {
        Unit.Description = "Run signal-cli every day";
        Timer = {
          OnCalendar = "daily";
          Persistent = true;
        };
        Install.WantedBy = [ "timers.target" ];
      };
      services.signal-cli-receive = {
        Unit.Description = "Run signal-cli receive";
        Service = {
          Type = "exec";
          ExecStart = "${lib.getExe pkgs.signal-cli} receive --ignore-attachments";
        };
      };
    };
  };
}
