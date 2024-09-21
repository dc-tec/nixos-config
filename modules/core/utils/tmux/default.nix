{
  config,
  pkgs,
  lib,
  ...
}: {
  config = {
    programs.tmux = {
      enable = true;
      keymode = "vi";
      baseIndex = 1;
      clock24 = true;
      historyLimit = 100000;
      prefix = "C-a";
      extraConfig = ''
      '';

      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''

          '';
        }
      ];
    };
  };
}
