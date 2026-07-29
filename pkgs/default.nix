{
  pkgs,
  inputs,
  ...
}:
let
  forgeTools = pkgs.callPackage ./forge-tools { };
in
{
  forge-tools = forgeTools.bundle;
  nh-darwin-switch-publish = forgeTools.nhDarwinSwitchPublish;
  provision-forge-backup-secret = forgeTools.provisionForgeBackupSecret;
  provision-forge-cache-key = forgeTools.provisionForgeCacheKey;
  publish-forge-cache = forgeTools.publishForgeCache;
  niks-cli = pkgs.callPackage ./niks { inherit inputs; };
}
