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
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "terraform"
      ];
    environment.systemPackages = with pkgs; [
      tenv
      terraform-docs
    ];
  };
}
