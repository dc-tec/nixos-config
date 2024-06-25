{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development = {
      packer.enable = lib.mkEnableOption "Packer";
    };
  };

  config = lib.mkIf config.dc-tec.development.packer.enable {
    home-manager.users.roelc = {
      home.packages = with pkgs; [
        packer
      ];
    };
  };
}
