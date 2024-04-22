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
    environment.systemPackages = with pkgs; [
      tenv
      terraform
      terraform-docs
    ];
  };
}
