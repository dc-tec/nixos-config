{
  config,
  lib,
  ...
}: {
  imports = [
    ./connectivity
    ./desktop
    ./storage
    ./virtualization
    ./system.nix
  ];
}