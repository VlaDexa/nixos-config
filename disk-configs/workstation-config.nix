{
  nvme ? "/dev/disk/by-id/nvme-Samsung_SSD_980_1TB_S649NL1T704305D_1",
  big-ssd ? "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_2TB_S6P4NX0W200498D",
  small-ssd ? "/dev/disk/by-id/ata-Samsung_SSD_870_QVO_1TB_S5SVNF0NB68509K",
  hard-drive ? "/dev/disk/by-id/ata-ST4000VN006-3CW104_WW658ZQ6",
  ...
}:
{
  disko.devices = {
    disk = {
      nvme = {
        device = nvme;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            windows = {
              size = "250G";
              type = "0700";
            };
            main = {
              size = "100%";
              content = {
                type = "bcachefs";
                filesystem = "main_bcachefs";
                label = "nvme.first";
                extraFormatArgs = [ "--discard" ];
              };
            };
          };
        };
      };
      big-ssd = {
        device = big-ssd;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            main = {
              size = "100%";
              content = {
                type = "bcachefs";
                filesystem = "main_bcachefs";
                label = "ssd.big";
                extraFormatArgs = [ "--discard" ];
              };
            };
          };
        };
      };
      small-ssd = {
        device = small-ssd;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            main = {
              size = "100%";
              content = {
                type = "bcachefs";
                filesystem = "main_bcachefs";
                label = "ssd.small";
                extraFormatArgs = [ "--discard" ];
              };
            };
          };
        };
      };
      hard-drive = {
        device = hard-drive;
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            main = {
              size = "100%";
              # content = {
              #   type = "bcachefs";
              #   filesystem = "main_bcachefs";
              #   label = "hdd.backup";
              # };
            };
          };
        };
      };
    };

    bcachefs_filesystems = {
      main_bcachefs = {
        type = "bcachefs_filesystem";
        extraFormatArgs = [
          "--compression=zstd"
          "--background_compression=zstd:15"
          "--replicas=2"
          # "--background_target=hdd"
          # "--foreground_target=ssd"
          # "--promote_target=ssd"
          "--metadata_target=nvme"
        ];
        subvolumes = {
          "subvolumes/root" = {
            mountpoint = "/";
          };
          "subvolumes/home" = {
            mountpoint = "/home";
          };
          "subvolumes/nix" = {
            mountpoint = "/nix";
            mountOptions = [
              "noatime"
            ];
          };
        };
      };
      next_bcachefs = {
        type = "bcachefs_filesystem";
        extraFormatArgs = [
          "--compression=zstd"
          "--background_compression=zstd:15"
          "--replicas=2"
          "--background_target=hdd"
          "--foreground_target=ssd"
          "--promote_target=ssd"
          # "--metadata_target=nvme"
        ];
        subvolumes = {
          "subvolumes/root" = {
            mountpoint = "/";
          };
          "subvolumes/home" = {
            mountpoint = "/home";
          };
          "subvolumes/nix" = {
            mountpoint = "/nix";
            mountOptions = [
              "noatime"
            ];
          };
        };
      }
    };
  };
}

# vim: ts=2 sw=2 et:
