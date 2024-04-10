{ config, lib, pkgs, ... }: {

  imports = [
    ./hyprland
    ./xdg
    ./terminal
  ];

  options.dc-tec.graphical = {
    enable = lib.mkEnableOption "graphical environment";
    laptop = lib.mkEnableOption "laptop configuration";
  };

  config = lib.mkIf config.dc-tec.graphical.enable {
    dc-tec = {
      graphical = {
        hyprland.enable = lib.mkDefault true;
        terminal.enable = lib.mkDefault true;
        xdg.enable = lib.mkDefault true;
      };
    };
  };
}
