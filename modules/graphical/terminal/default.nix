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
        settings = {
          enable_audio_bell = false;
          enable_visual_bell = false;
          remember_window_size = false;
          confirm_os_window_close = 0;

          # Window config
          window_margin_width = 5;
          single_window_margin_width = -1;
        };
      };
    };
  };
}
