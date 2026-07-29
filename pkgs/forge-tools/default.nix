{
  lib,
  coreutils,
  nh,
  nix,
  openssh,
  symlinkJoin,
  writeShellApplication,
}:
let
  mkTool =
    {
      name,
      source,
      runtimeInputs,
      runtimeEnv ? null,
      description,
    }:
    writeShellApplication {
      inherit
        name
        runtimeInputs
        runtimeEnv
        ;
      text = builtins.readFile source;
      meta = {
        inherit description;
        license = lib.licenses.unlicense;
        mainProgram = name;
        platforms = lib.platforms.unix;
      };
    };

  publishForgeCache = mkTool {
    name = "publish-forge-cache";
    source = ./publish-forge-cache.bash;
    runtimeInputs = [
      nix
      openssh
    ];
    description = "Copy and sign realized Nix store paths in the Forge cache";
  };

  provisionForgeBackupSecret = mkTool {
    name = "provision-forge-backup-secret";
    source = ./provision-forge-backup-secret.bash;
    runtimeInputs = [ openssh ];
    description = "Provision the Forge Restic repository password over WireGuard SSH";
  };

  provisionForgeCacheKey = mkTool {
    name = "provision-forge-cache-key";
    source = ./provision-forge-cache-key.bash;
    runtimeInputs = [
      nix
      openssh
    ];
    runtimeEnv.FORGE_CACHE_PUBLIC_KEY_FILE = ../../keys/forge-cache.pub;
    description = "Verify and provision the Forge binary-cache signing key";
  };

  nhDarwinSwitchPublish = mkTool {
    name = "nh-darwin-switch-publish";
    source = ./nh-darwin-switch-publish.bash;
    runtimeInputs = [
      coreutils
      nh
      nix
      publishForgeCache
    ];
    description = "Activate a Darwin generation and publish its closure to Forge";
  };
in
{
  inherit
    nhDarwinSwitchPublish
    provisionForgeBackupSecret
    provisionForgeCacheKey
    publishForgeCache
    ;

  bundle = symlinkJoin {
    name = "forge-tools";
    paths = [
      nhDarwinSwitchPublish
      provisionForgeBackupSecret
      provisionForgeCacheKey
      publishForgeCache
    ];
  };
}
