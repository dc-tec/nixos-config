{
  config,
  lib,
  pkgs,
  ...
}: {
  options.dc-tec.core = {
    zfs = {
      # Enable ZFS
      enable = lib.mkEnableOption "zfs";
      # Ask for credentials
      encrypted = lib.mkEnableOption "zfs request credentials";

      # Clear our symbolic links
      systemCacheLinks = lib.mkOption {
        default = [];
        description = "List of system cache directories to persist";
      };
      systemDataLinks = lib.mkOption {
        default = [];
        description = "List of system data directories to persist";
      };
      homeCacheLinks = lib.mkOption {
        default = [];
        description = "List of home cache directories to persist";
      };
      homeDataLinks = lib.mkOption {
        default = [];
        description = "List of home data directories to persist";
      };

      ensureSystemExists = lib.mkOption {
        default = [];
        example = ["/data/etc/ssh"];
        description = "List of system directories to ensure exist on boot";
      };
      ensureHomeExists = lib.mkOption {
        default = [];
        example = [".ssh"];
        description = "List of home directories to ensure exist on boot";
      };
      rootDataset = lib.mkOption {
        default = "";
        example = "rpool/local/root";
        description = "ZFS root dataset for rollback functionality";
      };
    };
  };

  config = {
    dc-tec = {
      core = {
        zfs = {
          enable = lib.mkDefault true;
        };
      };
    };

    environment.persistence."${config.dc-tec.persistence.cachePrefix}" = lib.mkIf config.dc-tec.persistence.enable {
      hideMounts = true;
      directories = config.dc-tec.core.zfs.systemCacheLinks;
      users.roelc.directories = config.dc-tec.core.zfs.homeCacheLinks;
    };

    environment.persistence."${config.dc-tec.persistence.dataPrefix}" = lib.mkIf config.dc-tec.persistence.enable {
      hideMounts = true;
      directories = config.dc-tec.core.zfs.systemDataLinks;
      users.roelc.directories = config.dc-tec.core.zfs.homeDataLinks;
    };

    boot = lib.mkIf config.dc-tec.core.zfs.enable {
      supportedFilesystems = ["zfs"];
      zfs = {
        devNodes = "/dev/";
        requestEncryptionCredentials = config.dc-tec.core.zfs.encrypted;
      };
      initrd.postDeviceCommands = lib.mkIf (config.dc-tec.persistence.enable && config.dc-tec.core.zfs.rootDataset != "") (lib.mkAfter ''
        zfs rollback -r ${config.dc-tec.core.zfs.rootDataset}@blank
      '');
    };

    services = lib.mkIf config.dc-tec.core.zfs.enable {
      zfs = {
        autoScrub.enable = true;
        trim.enable = true;
      };
    };

    environment.systemPackages = lib.mkIf (config.dc-tec.core.zfs.enable && config.dc-tec.persistence.enable && config.dc-tec.core.zfs.rootDataset != "") [
      (pkgs.writeScriptBin "zfsdiff" ''
        doas zfs diff ${config.dc-tec.core.zfs.rootDataset}@blank -F | ${pkgs.ripgrep}/bin/rg -e "\+\s+/\s+" | cut -f3- | ${pkgs.skim}/bin/sk --query "/home/roelc/"
      '')
    ];

    system.activationScripts = lib.mkIf config.dc-tec.persistence.enable (let
      ensureSystemExistsScript =
        lib.concatStringsSep "\n"
        (map (path: ''mkdir -p "${path}"'')
          config.dc-tec.core.zfs.ensureSystemExists);
      ensureHomeExistsScript = lib.concatStringsSep "\n" (map
        (path: ''
          mkdir -p "/home/roelc/${path}"; chown roelc:users /home/roelc/${path}
        '')
        config.dc-tec.core.zfs.ensureHomeExists);
    in {
      ensureSystemPathsExist = {
        text = ensureSystemExistsScript;
        deps = [];
      };
      ensureHomePathsExist = {
        text = ''
          mkdir -p /home/roelc/
          ${ensureHomeExistsScript}
        '';
        deps = ["users" "groups"];
      };
    });
  };
}
