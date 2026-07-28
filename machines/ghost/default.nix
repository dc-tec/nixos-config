{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  wsl = {
    enable = true;

    defaultUser = config.dc-tec.user.name;
  };

  networking = {
    hostName = "ghost";
    hostId = "3c4e8b4f";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  system.autoUpgrade.enable = false;

  dc-tec = {
    stateVersion = "24.05";
    gpg.enable = true;
    persistence.enable = false;
    core.zfs.enable = false;
  };
}
