{ config, lib, ... }:
{
  config = {
    dc-tec.core.zfs = lib.mkMerge [
      (
        lib.mkIf config.dc-tec.persistence.enable
        && config.dc-tec.isLinux {
          systemDataLinks = [ "/var/lib/nixos" ];
        }
      )
      (lib.mkIf (!config.dc-tec.persistence.enable && config.dc-tec.isLinux) { })
    ];
  };

  security = {
    sudo = {
      enable = false;
    };

    doas = {
      enable = true;
      extraRules = [
        {
          users = [ "roelc" ];
          noPass = true;
        }
      ];
    };

    polkit = {
      enable = true;
    };
  };

  services = {
    fwupd = {
      enable = true;
    };
  };

  i18n = {
    defaultLocale = "en_IE.UTF-8";
    extraLocaleSettings = {
      LC_ALL = "en_IE.UTF-8";
      LANGUAGE = "en_US.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
    supportedLocales = [
      "en_GB.UTF-8/UTF-8"
      "en_IE.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };
}

