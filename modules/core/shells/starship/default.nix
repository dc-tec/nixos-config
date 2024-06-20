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
          "$directory"
          "$git_branch"
          "$git_status"
          "$direnv"
          "$cmd_duration"
          "\n󱞪(2) $character"
        ];

        git_status = {
          conflicted = " \${count}x ";
          ahead = " \${count}x ";
          behind = " \${count}x ";
          diverged = "󱐎 \${count}x ";
          untracked = "\${count}x ";
          stashed = "󰆔 \${count}x ";
          modified = "󰴓\${count}x ";
          staged = "󰅕\${count}x ";
          renamed = "󰑕\${count}x ";
          deleted = " \${count}x ";
        };

        directory = {
          home_symbol = " ";
          read_only = " ";
        };

        direnv = {
          disabled = false;
          symbol = "󱃼 ";
          format = "[$symbol]($style) ";
          style = "12";
        };

        line_break = {
          disabled = true;
        };
      };
    };
  };
in {
  home-manager.users.roelc = {...}: (base "/home/roelc");
}
