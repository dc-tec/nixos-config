{pkgs, ...}: {
  dc-tec = {
    niks-cli = pkgs.callPackage ./niks {};
  };
}
