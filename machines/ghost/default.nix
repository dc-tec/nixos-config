{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

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
      zfs = {
        enable = false;
      };
      wireless = {
        enable = false;
      };
    };
    graphical = {
      enable = false;
      xdg = {
        enable = true;
      };
    };
  };
}
