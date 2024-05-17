{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development = {
      packer.enable = lib.mkEnableOption "Terraform";
    };
  };

  config = lib.mkIf config.dc-tec.development.packer.enable {
    environment.systemPackages = with pkgs; [
      packer
    ];
  };
}
