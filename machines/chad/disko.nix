{ ... }:
let
  zfsPartition = pool: {
    size = "100%";
    content = {
      type = "zfs";
      inherit pool;
    };
  };
  filesystem = mountpoint: {
    type = "zfs_fs";
    inherit mountpoint;
    options.mountpoint = "legacy";
  };
  encryptedRoot = {
    canmount = "off";
    mountpoint = "none";
    compression = "lz4";
    atime = "off";
    xattr = "sa";
    acltype = "posixacl";
    encryption = "aes-256-gcm";
    keyformat = "passphrase";
    # Supplied interactively in the RAM installer; never committed or logged.
    keylocation = "file:///run/chad-install/pool.key";
  };
in
{
  disko.devices = {
    disk = {
      ssd-boot = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x5002538d42594eae";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = zfsPartition "rpool";
          };
        };
      };
      ssd-data = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x5002538d426746d4";
        content = {
          type = "gpt";
          partitions.zfs = zfsPartition "rpool";
        };
      };
      hdd-bulk = {
        type = "disk";
        device = "/dev/disk/by-id/wwn-0x5000c500a22f749d";
        content = {
          type = "gpt";
          partitions.zfs = zfsPartition "bulk";
        };
      };
    };
    zpool = {
      rpool = {
        type = "zpool";
        options = {
          ashift = "12";
          compatibility = "openzfs-2.4-linux";
          autotrim = "on";
          cachefile = "none";
        };
        rootFsOptions = encryptedRoot;
        postCreateHook = "zfs set keylocation=prompt rpool";
        datasets = {
          local = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          safe = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "local/root" = filesystem "/";
          "local/nix" = filesystem "/nix";
          "local/nix-store" = filesystem "/nix/store";
          "local/cache" = filesystem "/cache";
          "local/lab" = filesystem "/cache/var/lib/libvirt";
          "safe/data" = filesystem "/data";
        };
      };
      bulk = {
        type = "zpool";
        options = {
          ashift = "12";
          compatibility = "openzfs-2.4-linux";
          cachefile = "none";
        };
        rootFsOptions = encryptedRoot;
        datasets = { };
        # Keep this dataset outside the generated boot filesystem dependencies.
        postCreateHook = ''
          zfs set keylocation=prompt bulk
          zfs create -o mountpoint=/bulk -o canmount=noauto bulk/data
        '';
      };
    };
  };
}
