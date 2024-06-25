{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development = {
      go.enable = lib.mkEnableOption "Go";
    };
  };

  config = lib.mkIf config.dc-tec.development.go.enable {
    home-manager.users.roelc = {
      home.packages = with pkgs; [
        go
      ];
    };
  };
}
