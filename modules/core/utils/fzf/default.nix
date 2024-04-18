{config, ...}: let
  base = home: {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      colors = {
        bg = "#${config.colorScheme.palette.base00}";
        fg = "#${config.colorScheme.palette.base05}";
        preview-fg = "#${config.colorScheme.palette.base06}";
        preview-bg = "#${config.colorScheme.palette.base01}";
        hl = "#${config.colorScheme.palette.base02}";
        "fg+" = "#${config.colorScheme.palette.base03}";
        "bg+" = "#${config.colorScheme.palette.base02}";
        gutter = "#${config.colorScheme.palette.base02}";
        "hl+" = "#${config.colorScheme.palette.base0B}";
        info = "#${config.colorScheme.palette.base00}";
        border = "#${config.colorScheme.palette.base02}";
        prompt = "#${config.colorScheme.palette.base01}";
        pointer = "#${config.colorScheme.palette.base03}";
        marker = "#${config.colorScheme.palette.base00}";
        spinner = "#${config.colorScheme.palette.base00}";
        header = "#${config.colorScheme.palette.base00}";
      };
    };
  };
in {
  home-manager.users.roelc = {...}: (base "/home/roelc");
}
