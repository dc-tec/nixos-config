{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development = {
      python312.enable = lib.mkEnableOption "Python 3.12";
    };
  };

  config = lib.mkIf config.dc-tec.development.python312.enable {
    environment.systemPackages = with pkgs; [
      python312
    ];
  };
}
