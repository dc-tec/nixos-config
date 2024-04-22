{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development = {
      aws-cli.enable = lib.mkEnableOption "AWS CLI";
    };
  };

  config = lib.mkIf config.dc-tec.development.aws-cli.enable {
    environment.systemPackages = with pkgs; [
      awscli2
    ];
  };
}
