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
    environment.systemPackages = with pkgs; [
      go
    ];
  };
}
