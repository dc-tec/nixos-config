{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  users = {
    mutableUsers = true;
    users = {
      roelc = {
        isNormalUser = true;
        home = "/home/roelc";
        extraGroups = ["systemd-journal"];
      };
    };
  };

  wsl = {
    enable = true;

    defaultUser = "roelc";
  };

  networking = {
    hostName = "ghost";
    hostId = "3c4e8b4f";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  dc-tec = {
    stateVersion = "24.05";
    core = {
      persistence = {
        enable = false;
      };
      zfs = {
        enable = false;
      };
    };
    development = {
      virtualisation = {
        hypervisor = {
          enable = false;
        };
        docker = {
          enable = false;
        };
      };
    };
  };
}
