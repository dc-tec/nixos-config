{config, ...}: {
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      catppuccin.kitty.enable = true;
      programs.kitty = {
        enable = true;
      font = {
        name = config.dc-tec.font;
        size = if config.dc-tec.isDarwin then 11 else 10;
      };
      settings = {
        enable_audio_bell = false;
        enable_visual_bell = false;
        remember_window_size = false;
        confirm_os_window_close = 0;
        disable_ligatures = "always";

        # Font config
        font_family = config.dc-tec.font;
        adjust_line_height = 3;

        background_opacity = "0.8";
        background_blur = 20;

        # Window config
        window_margin_width = 5;
        single_window_margin_width = -1;
      };
    };
  };
}
