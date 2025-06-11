{pkgs, ...}: {
  niks-cli = pkgs.callPackage ./niks {};
}
