{ lib, ... }:
{
  nixpkgs.overlays = lib.mkAfter [ (import ../overlays/build-compatibility.nix) ];
}
