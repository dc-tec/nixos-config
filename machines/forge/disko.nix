{ lib, ... }:
let
  mkDurableDisk = device: {
    inherit device;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        bios = {
          size = "2M";
          type = "EF02";
        };
        boot = {
          size = "1G";
          type = "FD00";
          content = {
            type = "mdraid";
            name = "forge-boot";
          };
        };
        root = {
          size = "100%";
          type = "FD00";
          content = {
            type = "mdraid";
            name = "forge-root";
          };
        };
      };
    };
  };
in
{
  disko.devices = {
    disk = {
      durable-a = mkDurableDisk (lib.mkDefault "/dev/disk/by-id/wwn-0x500a07511756b6c8");
      durable-b = mkDurableDisk (lib.mkDefault "/dev/disk/by-id/wwn-0x500a07511756abda");
      cache = {
        type = "disk";
        device = lib.mkDefault "/dev/disk/by-id/wwn-0x500a075115a7a32f";
        content = {
          type = "gpt";
          partitions.cache = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              extraArgs = [
                "-L"
                "forge-cache"
              ];
              mountpoint = "/cache";
              mountOptions = [
                "defaults"
                "noatime"
                "nofail"
                "x-systemd.device-timeout=5s"
              ];
            };
          };
        };
      };
    };

    mdadm = {
      forge-boot = {
        type = "mdadm";
        level = 1;
        metadata = "1.0";
        content = {
          type = "filesystem";
          format = "ext4";
          extraArgs = [
            "-L"
            "forge-boot"
          ];
          mountpoint = "/boot";
          mountOptions = [
            "defaults"
            "noatime"
          ];
        };
      };

      forge-root = {
        type = "mdadm";
        level = 1;
        metadata = "1.2";
        content = {
          type = "filesystem";
          format = "ext4";
          extraArgs = [
            "-L"
            "forge-root"
          ];
          mountpoint = "/";
          mountOptions = [
            "defaults"
            "noatime"
          ];
        };
      };
    };
  };
}
