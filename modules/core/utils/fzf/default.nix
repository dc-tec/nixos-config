{ config, lib, pkgs, ... }:

let
  base = (home: {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      colors = rec {
        bg = "#${config.colorScheme.colors.base00}";
        fg = "#${config.colorScheme.colors.base05}";
        preview-fg = "#${config.colorScheme.colors.base06}";
        preview-bg = "#${config.colorScheme.colors.base01}";
        hl = "#${config.colorScheme.colors.base02}";
        fg+ = "#${config.colorScheme.colors.base03}";
        bg+ = "#${config.colorScheme.colors.base02}";
        gutter = bg+;
        hl+ = "#${config.colorScheme.colors.base0B}";
        info = "#${config.colorScheme.colors.base00}";
        border = "#${config.colorScheme.colors.base02}";
        prompt = "#${config.colorScheme.colors.base01}";
        pointer = "#${config.colorScheme.colors.base03}";
        marker = "#${config.colorScheme.colors.base00}";
        spinner = "#${config.colorScheme.colors.base00}";
        header = "#${config.colorScheme.colors.base00}";
      };
    };
  });

in
{
  home-manager.users.roelc = { ... }: (base "/home/roelc");
}
