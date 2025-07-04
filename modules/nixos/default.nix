{
  config,
  lib,
  ...
}: {
  imports = [
    ./connectivity
    ./desktop
    ./services
    ./storage
    ./system.nix
    ./utils
    ./virtualization
  ];
}