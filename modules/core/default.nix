{ config, lib, pkgs, ... }:

{
  imports = [
    ./zfs 
    ./zsh 
    ./ssh 
    ./sshd 
    ./network
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

    home-manager.users = { 
      roelc = { ... }: {
        home.stateVersion = config.dc-tec.stateVersion;
        systemd.user.sessionVariables = config.home-manager.users.roelc.home.sessionVariables;
      };
      root = { ... }: { home.stateVersion = config.dc-tec.stateVersion; };
    };

    environment = {
      systemPackages = with pkgs; [
        wget
        curl
        ripgrep
        fzf
        git
        vim
        z-lua
        bat
        eza
	bottom
      ];
    };

    fonts = {
      packages = with pkgs; [
	(nerdfonts.override { fonts = [ "0xProto" ]; })
      ];
    };
    
    security = { 
      sudo = {
        enable = false;
      };

      doas = {
        enable = true;
        extraRules = [{
          users = [ "roelc" ];
          noPass = true;
        }]; 
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

    users = {
      mutableUsers = false;
      defaultUserShell = pkgs.zsh;
      users = {
        roelc = {
          isNormalUser = true;
          home = "/home/roelc";
          extraGroups = [ "systemd-journal" ];
	  hashedPasswordFile = config.age.secrets."secrets/passwords/users/roelc".path;
        };
	root.hashedPasswordFile = config.age.secrets."secrets/passwords/users/root".path;
      };
    };
    age.secrets."secrets/passwords/users/roelc".file = ../../secrets/passwords/users/roelc.age;
    age.secrets."secrets/passwords/users/root".file = ../../secrets/passwords/users/root.age;
  };
}

