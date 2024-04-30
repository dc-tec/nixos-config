{lib, ...}: let
  base = home: {
    programs.starship = {
      enable = true;
      catppuccin.enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        command_timeout = 1000;
        character = {
          success_symbol = "[󱄅 ❯](bold green)";
          error_symbol = "[󱄅 ❯](bold red)";
        };
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
