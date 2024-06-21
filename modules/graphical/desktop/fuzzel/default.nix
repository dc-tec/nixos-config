{
  config,
  lib,
  pkgs,
  ...
}: {
  options.dc-tec.graphical.fuzzel = {
    enable = lib.mkEnableOption "fuzzel";
  };

  config = lib.mkIf config.dc-tec.graphical.fuzzel.enable {
    home-manager.users.roelc = {
      home.packages = with pkgs; [
        papirus-icon-theme
      ];

      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            terminal = "${pkgs.kitty}/bin/kitty";
            layer = "overlay";
            icon-theme = "Papirus-Dark";
            prompt = " ";
            font = "0xProto Nerd Font";
          };
          colors = {
            background = "24273add";
            text = "cad3f5ff";
            selection = "5b6078ff";
            selection-text = "cad3f5ff";
            border = "b7bdf8ff";
            match = "ed8796ff";
            selection-match = "ed8796ff";
          };
          border = {
            radius = "10";
            width = "1";
          };
          dmenu = {
            exit-immediately-if-empty = "yes";
          };
        };
      };
    };
  };
}
