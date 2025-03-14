{...}: {
  home-manager.users.roelc = {
    catppuccin.kitty.enable = true;
    programs.kitty = {
      enable = true;
      font = {
        name = "0xProto";
        size = 11;
      };
      settings = {
        enable_audio_bell = false;
        remember_window_size = true;
        confirm_os_window_close = 0;
        disable_ligatures = "always";

        # Font config
        font_family = "0xProto";
        adjust_line_height = 3;

        background_opacity = "0.8";
        background_blur = 20;

        # Window config
        window_margin_width = 5;
        single_window_margin_width = -1;
      };
      #extraConfig = ''
      #  modify_font cell_height 103%
      #'';
    };
  };
}
