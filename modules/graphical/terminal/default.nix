{
  config,
  lib,
  ...
}: {
  options.dc-tec.graphical.terminal.enable = lib.mkEnableOption "terminal";

  config = lib.mkIf config.dc-tec.graphical.terminal.enable {
    home-manager.users.roelc = {pkgs, ...}: {
      programs.kitty = {
        enable = true;
        catppuccin.enable = true;
        font = {
          name = "0xProto Nerd Font";
          size = 10;
        };
        settings = {
          enable_audio_bell = false;
          enable_visual_bell = false;
          remember_window_size = false;
          confirm_os_window_close = 0;
          disable_ligatures = "always";

          # Font config
          font_family = "0xProto Nerd Font";
          adjust_line_height = 3;

          # Window config
          window_margin_width = 5;
          single_window_margin_width = -1;
        };
        #extraConfig = ''
        #  modify_font cell_height 103%
        #'';
      };
    };
  };
}
