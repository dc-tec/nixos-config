{ lib, pkgs, config, ... }: {
  options.dc-tec.user = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "roelc";
      description = "Primary user name";
    };

    fullName = lib.mkOption {
      type = lib.types.str;
      default = "Roel de Cort";
      description = "User full name";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "roel@decort.tech";
      description = "User email address";
    };

    workEmail = lib.mkOption {
      type = lib.types.str;
      default = "roel.decort@adfinis.com";
      description = "Work email address";
    };

    gpgKey = lib.mkOption {
      type = lib.types.str;
      default = "F95CABF0B7D54D8087FF9B3E321EAD1FC3C51961";
      description = "User GPG key";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.str;
      description = "User home directory";
    };

    shell = lib.mkOption {
      type = lib.types.str;
      default = "zsh";
      description = "Default shell";
    };
  };

  config = {
    dc-tec.user.homeDirectory = lib.mkDefault (
      if config.dc-tec.isDarwin
      then "/Users/${config.dc-tec.user.name}"
      else "/home/${config.dc-tec.user.name}"
    );
  };
}