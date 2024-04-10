{ config, lib, pkgs, ... }: {

  imports = [
    ./hyprland
    ./xdg
  ];

  options.dc-tec.graphical = {
    enable = lib.mkEnableOption "graphical environment";
    laptop = lib.mkEnableOption "laptop configuration";
  };

  config = lib.mkIf config.dc-tec.graphical.enable {
    dc-tec = {
      graphical = {
        hyprland.enable = lib.mkDefault true;
      };
    };
  };
}
