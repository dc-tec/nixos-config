{
  inputs,
  lib,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";

  networking = {
    hostName = "darwin";
    computerName = "darwin";
  };
}