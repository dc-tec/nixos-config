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
    dc-tec.core.zfs.homeCacheLinks = lib.mkIf config.dc-tec.core.persistence.enable [".azure"];

    environment.systemPackages = with pkgs; [
      azure-cli
      bicep
    ];
  };
}
