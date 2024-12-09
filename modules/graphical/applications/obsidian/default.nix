{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.dc-tec.graphical.applications.obsidian.enable = lib.mkEnableOption "obsidian";

  config = lib.mkIf config.dc-tec.graphical.applications.obsidian.enable {
    environment.systemPackages = with pkgs; [
      obsidian
    ];
  };
}
