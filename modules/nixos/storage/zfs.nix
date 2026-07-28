{
  config,
  lib,
  pkgs,
  ...
}:
let
  persistenceDirectory = lib.types.either lib.types.str lib.types.attrs;
  user = config.dc-tec.user.name;
  userHome = config.dc-tec.user.homeDirectory;
  rootSnapshot = "${config.dc-tec.core.zfs.rootDataset}@blank";
  rootPool = builtins.head (lib.splitString "/" config.dc-tec.core.zfs.rootDataset);
  rollbackEnabled = config.dc-tec.persistence.enable && config.dc-tec.core.zfs.rootDataset != "";
in
{
  options.dc-tec.core = {
    zfs = {
      # Enable ZFS
      enable = lib.mkEnableOption "zfs";
      # Ask for credentials
      encrypted = lib.mkEnableOption "zfs request credentials";

      # Clear our symbolic links
      systemCacheLinks = lib.mkOption {
        type = lib.types.listOf persistenceDirectory;
        default = [ ];
        description = "System cache directory specifications to persist below the configured cache prefix.";
      };
      systemDataLinks = lib.mkOption {
        type = lib.types.listOf persistenceDirectory;
        default = [ ];
        description = "System data directory specifications to persist below the configured data prefix.";
      };
      homeCacheLinks = lib.mkOption {
        type = lib.types.listOf persistenceDirectory;
        default = [ ];
        description = "Home-relative cache directory specifications to persist below the configured cache prefix.";
      };
      homeDataLinks = lib.mkOption {
        type = lib.types.listOf persistenceDirectory;
        default = [ ];
        description = "Home-relative data directory specifications to persist below the configured data prefix.";
      };

      ensureSystemExists = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "/data/etc/ssh" ];
        description = "System directories to create during activation.";
      };
      ensureHomeExists = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ ".ssh" ];
        description = "Home-relative directories to create during activation.";
      };
      rootDataset = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "rpool/local/root";
        description = "ZFS root dataset to roll back to its blank snapshot during early boot.";
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

    environment.persistence."${config.dc-tec.persistence.cachePrefix}" =
      lib.mkIf config.dc-tec.persistence.enable
        {
          hideMounts = true;
          directories = config.dc-tec.core.zfs.systemCacheLinks;
          users.${user}.directories = config.dc-tec.core.zfs.homeCacheLinks;
        };

    environment.persistence."${config.dc-tec.persistence.dataPrefix}" =
      lib.mkIf config.dc-tec.persistence.enable
        {
          hideMounts = true;
          directories = config.dc-tec.core.zfs.systemDataLinks;
          users.${user}.directories = config.dc-tec.core.zfs.homeDataLinks;
        };

    boot = lib.mkIf config.dc-tec.core.zfs.enable {
      supportedFilesystems = [ "zfs" ];
      zfs = {
        devNodes = "/dev/";
        requestEncryptionCredentials = config.dc-tec.core.zfs.encrypted;
      };
      initrd.systemd.services.rollback-root = lib.mkIf rollbackEnabled {
        description = "Roll back the ZFS root dataset to its blank snapshot";
        after = [ "zfs-import-${rootPool}.service" ];
        before = [ "sysroot.mount" ];
        requiredBy = [ "sysroot.mount" ];
        path = [ config.boot.zfs.package ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          zfs rollback -r ${lib.escapeShellArg rootSnapshot}
        '';
      };
    };

    services = lib.mkIf config.dc-tec.core.zfs.enable {
      zfs = {
        autoScrub.enable = true;
        trim.enable = true;
      };
    };

    environment.systemPackages =
      lib.mkIf
        (
          config.dc-tec.core.zfs.enable
          && config.dc-tec.persistence.enable
          && config.dc-tec.core.zfs.rootDataset != ""
        )
        [
          (pkgs.writeScriptBin "zfsdiff" ''
            doas zfs diff ${lib.escapeShellArg rootSnapshot} -F | ${pkgs.ripgrep}/bin/rg -e "\+\s+/\s+" | cut -f3- | ${pkgs.skim}/bin/sk --query ${lib.escapeShellArg "${userHome}/"}
          '')
        ];

    system.activationScripts = lib.mkIf config.dc-tec.persistence.enable (
      let
        ensureSystemExistsScript = lib.concatStringsSep "\n" (
          map (path: "mkdir -p ${lib.escapeShellArg path}") config.dc-tec.core.zfs.ensureSystemExists
        );
        ensureHomeExistsScript = lib.concatStringsSep "\n" (
          map (path: ''
            mkdir -p ${lib.escapeShellArg "${userHome}/${path}"}
            chown ${lib.escapeShellArg "${user}:${user}"} ${lib.escapeShellArg "${userHome}/${path}"}
          '') config.dc-tec.core.zfs.ensureHomeExists
        );
      in
      {
        ensureSystemPathsExist = {
          text = ensureSystemExistsScript;
          deps = [ ];
        };
        ensureHomePathsExist = {
          text = ''
            mkdir -p ${lib.escapeShellArg userHome}
            ${ensureHomeExistsScript}
          '';
          deps = [
            "users"
            "groups"
          ];
        };
      }
    );
  };
}
