{
  lib,
  publicKeys,
  ...
}:
let
  cachePublicKey = publicKeys.nixCache.forge;
in
{
  assertions = [
    {
      assertion = lib.hasPrefix "cache.decort.tech-1:" cachePublicKey;
      message = "The forge binary-cache public key has an unexpected identity.";
    }
  ];

  nix.settings = {
    substituters = [ "https://cache.decort.tech?priority=30" ];
    trusted-public-keys = [ cachePublicKey ];
  };
}
