{ lib, pkgs, ... }:
{
  dc-tec = {
    isDarwin = pkgs.stdenv.isDarwin;
    isLinux = pkgs.stdenv.isLinux;
  };
}