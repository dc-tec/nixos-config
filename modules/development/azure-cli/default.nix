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
    environment.systemPackages = with pkgs; [
      azure-cli
    ];
  };
}
