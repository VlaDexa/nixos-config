{
  backup ? "/dev/disk/by-id/ata-ST4000DM004-2U9104_ZFN5KX49",
  ...
}:
{
  disko.devices = {
    disk = {
      backup = {
        type = "disk";
        device = backup;
        content = {
          type = "gpt";
          partitions = {
            main = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/mnt/Backup";
              };
            };
          };
        };
      };
    };
  };
}

# vim: ts=2 sw=2 et:
