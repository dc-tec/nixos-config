{ config, lib, pkgs, ... }: {

  options.dc-tec.core.zfs = {
    # Ask for credentials
    encrypted = lib.mkEnableOption "zfs request credentials";
    
    # Clear our symbolic links
    systemCacheLinks = lib.mkOption { default = [ ]; };
    systemDataLinks = lib.mkOption { default = [ ]; };
    homeCacheLinks = lib.mkOption { default = [ ]; };
    homeDataLinks = lib.mkOption { default = [ ]; };

    ensureSystemExists = lib.mkOption {
      default = [ ];
      example = [ "/data/etc/ssh" ]; 
    };
    ensureHomeExists = lib.mkOption {
      default = [ ];
      example = [ ".ssh" ]; 
    };
    rootDataset = lib.mkOption {
      example = "rpool/local/root";
    };
  };

  config = {
    dc-tec.dataPrefix = lib.mkDefault "/data";
    dc-tec.cachePrefix = lib.mkDefault "/cache";
    
    environment.persistence."${config.dc-tec.cachePrefix}" = {
      hideMounts = true;
      directories = config.dc-tec.core.zfs.systemCacheLinks;
      users.roelc.directories = config.dc-tec.core.zfs.homeDataLinks;
    };

    environment.persistence."${config.dc-tec.dataPrefix}" = {
      hideMounts = true;
      directories = config.dc-tec.core.zfs.systemDataLinks;
      users.roelc.directories = config.dc-tec.core.zfs.homeDataLinks;
    };

    boot = {
      supportedFilesystems = [ "zfs" ];
      zfs = {
        devNodes = "/dev/";
        requestEncryptionCredentials = config.dc-tec.core.zfs.encrypted;
      }; 
      initrd.postDeviceCommands = lib.mkAfter ''
        zfs rollback -r ${config.dc-tec.core.zfs.rootDataset}@blank
      '';
    };

    services = {
      zfs = {
        autoScrub.enable = true;
        trim.enable = true;
      };
    };

    environment.systemPackages = [
      (pkgs.writeScriptBin "zfsdiff" ''
        doas zfs diff ${config.dc-tec.core.zfs.rootDataset}@blank -F | ${pkgs.ripgrep}/bin/rg -e "\+\s+/\s+" | cut -f3- | ${pkgs.skim}/bin/sk --query "/home/roelc/"
      '')
    ];

    system.activationScripts = 
      let
        ensureSystemExistsScript = lib.concatStringsSep "\n"
          (map (path: ''mkdir -p "${path}"'')
            config.dc-tec.core.zfs.ensureSystemExists);
        ensureHomeExistsScript = lib.concatStringsSep "\n" (map
          (path:
            ''
              mkdir -p "/home/roelc/${path}"; chown roelc:users /home/roelc/${path}'')
          config.dc-tec.core.zfs.ensureHomeExists);
      in
      {
        ensureSystemPathsExist = {
          text = ensureSystemExistsScript;
          deps = [ "agenixNewGeneration" ];
        };
        ensureHomePathsExist = {
          text = ''
            mkdir -p /home/roelc/
            ${ensureHomeExistsScript}
          '';
          deps = [ "users" "groups" ];
        };
        agenixInstall.deps = [ "ensureSystemPathsExist" "ensureHomePathsExist" ];
      };
  };
}

