{lib, ...}: let
  base = home: {
    programs.starship = {
      enable = true;
      catppuccin.enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        command_timeout = 1000;
        format = lib.concatStrings [
          "$directory$character"
        ];

        right_format = lib.concatStrings [
          "$all"
        ];

        line_break = {
          disabled = true;
        };
      };
    };
  };
in {
  home-manager.users.roelc = {...}: (base "/home/roelc");
}
