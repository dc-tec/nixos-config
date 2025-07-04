{
  lib,
  pkgs,
  config,
  ...
}:
{
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
      default = "52BFF6CCB1DA1915821F741BF29959D9BAB9798F";
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

    editor = lib.mkOption {
      type = lib.types.str;
      default = "nvim";
      description = "Default editor";
    };
  };

  config = {
    dc-tec.user.homeDirectory = lib.mkDefault (
      if config.dc-tec.isDarwin then
        "/Users/${config.dc-tec.user.name}"
      else
        "/home/${config.dc-tec.user.name}"
    );

    users =
      # Add mutableUsers only on NixOS; nix-darwin does not have this option.
      (lib.optionalAttrs config.dc-tec.isLinux {
        mutableUsers = config.dc-tec.persistence.enable;
      })
      // {
        users.${config.dc-tec.user.name} = lib.mkMerge [
          # Base user configuration
          {
            home = config.dc-tec.user.homeDirectory;
          }
          # Linux-specific user configuration
          (lib.mkIf config.dc-tec.isLinux {
            isNormalUser = true;
            group = config.dc-tec.user.name;
            hashedPasswordFile = config.sops.secrets."users/${config.dc-tec.user.name}".path;
            extraGroups = lib.mkIf config.dc-tec.isLinux [ "systemd-journal" ];
          })
          # Darwin-specific user configuration (no extra fields needed)
        ];
        groups.${config.dc-tec.user.name} = { };
      };
  };
}
