{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development = {
      powershell.enable = lib.mkEnableOption "Powershell";
    };
  };

  config = lib.mkIf config.dc-tec.development.powershell.enable {
    environment.systemPackages = with pkgs; [
      powershell
    ];
  };
}
