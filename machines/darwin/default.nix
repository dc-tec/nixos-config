{
  inputs,
  lib,
  ...
}: {
  imports = [
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";

  networking = {
    hostName = "darwin";
    computerName = "darwin";
  };
}