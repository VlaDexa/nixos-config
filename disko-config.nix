# USAGE in your configuration.nix.
# Update devices to match your hardware.
# {
#  imports = [ ./disko-config.nix ];
#  disko.devices.disk.main.device = "/dev/sda";
# }
{
  disko.devices = {
    bcachefs_filesystems = {
      main_bcachefs = {
        type = "bcachefs_filesystem";
        passwordFile = "/tmp/bcachefs_password";
        subvolumes = {
          "subvolumes/rootfs" = {
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
    };
    disk = {
      main = {
        device = "/dev/nvme0n1";
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
            swap = {
              size = "8G";
              content = {
                type = "swap";
                discardPolicy = "once";
                resumeDevice = true;
                randomEncryption = false;
              };
            };
            root = {
              size = "100%";
              content = {
                type = "bcachefs";
                filesystem = "main_bcachefs";
              };
            };
          };
        };
      };
    };
  };
}
