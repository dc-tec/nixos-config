{ config, lib, pkgs, ... }:

{
  options.dc-tec.graphical.terminal.enable = lib.mkEnableOption "terminal";

  config = lib.mkIf config.dc-tec.graphical.terminal.enable {
    home-manager.users.roelc = { pkgs, ... }: {
      programs.kitty = {
        enable = true;
        font = {
          name = "0xProto";
          size = 10;
        };
        settings = {
          enable_audio_bell = false;
          visual_bell_duration = "0.25";
          remember_window_size = false;
          confirm_os_window_close = 0;
        };
      };
    };
  };
}
