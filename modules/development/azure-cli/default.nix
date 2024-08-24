{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development = {
      azure-cli.enable = lib.mkEnableOption "Azure CLI";
    };
  };

  config = lib.mkIf config.dc-tec.development.azure-cli.enable {
    dc-tec.core.zfs = lib.mkMerge [
      (lib.mkIf config.dc-tec.core.persistence.enable {
        homeCacheLinks = [".azure"];
      })
      (lib.mkIf (!config.dc-tec.core.persistence.enable) {})
    ];

    home-manager.users.roelc = {
      home.packages = with pkgs.stable; [
        azure-cli
        #bicep
      ];
    };
  };
}
