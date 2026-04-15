{
  pkgs,
  inputs,
  ...
}:
{
  niks-cli = pkgs.callPackage ./niks { inherit inputs; };
}
