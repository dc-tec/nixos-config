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
    home-manager.users.roelc = {
      home.packages = with pkgs; [
        (python312.withPackages
          (ps: [ps.requests ps.cryptography ps.docker]))
      ];
    };
  };
}
