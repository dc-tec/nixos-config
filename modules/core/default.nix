{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./nix
    ./connectivity
    ./shells
    ./storage
    ./utils
    ./sops

    inputs.nix-colors.homeManagerModules.default
  ];

  options.dc-tec = {
    stateVersion = lib.mkOption {
      example = "23.11";
    };

    dataPrefix = lib.mkOption {
      example = "/data";
    };

    cachePrefix = lib.mkOption {
      example = "/cache";
    };
  };

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
    };
    system = {
      stateVersion = config.dc-tec.stateVersion;
      autoUpgrade = {
        enable = lib.mkDefault true;
        flake = "github:dc-tec/nixos-config";
        dates = "01/04:00";
        randomizedDelaySec = "15min";
      };
    };
    # System wide default color scheme
    colorScheme = inputs.nix-colors.colorSchemes.catppuccin-macchiato;
    catppuccin = {
      flavour = "macchiato";
    };

    dc-tec.core.zfs.homeCacheLinks = [".config"];

    home-manager.users = {
      roelc = {...}: {
        imports = [
          inputs.catppuccin.homeManagerModules.catppuccin
        ];
        home.stateVersion = config.dc-tec.stateVersion;
        home.packages = [inputs.nixvim.packages.x86_64-linux.default];
        systemd.user.sessionVariables = config.home-manager.users.roelc.home.sessionVariables;
        catppuccin = {
          flavour = "macchiato";
          accent = "peach";
        };
      };
      root = _: {home.stateVersion = config.dc-tec.stateVersion;};
    };

    environment = {
      systemPackages = with pkgs; [
        wget
        curl
        coreutils
        direnv
        dnsutils
        lshw
        moreutils
        usbutils
        nmap
        util-linux
        whois
        unzip
        git
        age
        sops
        ssh-to-age
        nerdfetch
        (pkgs.callPackage ../../pkgs/niks {})
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
            users = ["roelc"];
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

    time = {
      timeZone = lib.mkDefault "Europe/Amsterdam";
    };

    i18n = {
      defaultLocale = "en_IE.UTF-8";
      extraLocaleSettings = {
        LC_TIME = "en_GB.UTF-8";
      };
      supportedLocales = [
        "en_GB.UTF-8/UTF-8"
        "en_IE.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ];
    };
    users = {
      mutableUsers = false;
      defaultUserShell = pkgs.zsh;
      users = {
        roelc = {
          isNormalUser = true;
          home = "/home/roelc";
          extraGroups = ["systemd-journal"];
          hashedPasswordFile = config.sops.secrets."users/roelc".path;
        };
        root.hashedPasswordFile = config.sops.secrets."users/root".path;
      };
    };
  };
}
