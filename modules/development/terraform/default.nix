{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development = {
      terraform.enable = lib.mkEnableOption "Terraform";
    };
  };

  config = lib.mkIf config.dc-tec.development.terraform.enable {
    dc-tec.core.zfs.homeCacheLinks = lib.mkIf config.dc-tec.core.persistence.enable [".tenv"];

    home-manager.users.roelc = {
      home.packages = with pkgs; [
        tenv
        terraform-docs
      ];
    };
  };
}
