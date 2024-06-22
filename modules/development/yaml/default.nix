{
  config,
  lib,
  pkgs,
  ...
}: {
  options.dc-tec.development.yamlls.enable = lib.mkEnableOption "yamlls";

  config = lib.mkIf config.dc-tec.development.yamlls.enable {
    home-manager.users.roelc = {
      home.packages = with pkgs; [
        yaml-language-server
      ];
    };
  };
}
