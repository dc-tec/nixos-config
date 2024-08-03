{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development = {
      hashicorp.enable = lib.mkEnableOption "Hashicorp";
    };
  };

  config = lib.mkIf config.dc-tec.development.hashicorp.enable {
    dc-tec.core.zfs.homeCacheLinks = lib.mkIf config.dc-tec.core.persistence.enable [".tenv"];

    home-manager.users.roelc = {
      home.packages = with pkgs; [
        tenv
        terraform-docs
        vault
        consul
        packer
      ];
    };
  };
}
