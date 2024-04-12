{ config, lib, pkgs, ... }:

let
  base = (home: {
    home.packages = [
      pkgs.autojump # jump to recent directory. ex "j nix"
      pkgs.comma    # nix run shortcut. ex ", cowsay neato"
    ];
    programs.zsh = {
      enable = true;
      autosuggestion = {
	enable = true;
      };
      autocd = true;
      history = {
        expireDuplicatesFirst = true;
        path = "${config.dc-tec.cachePrefix}${home}/.local/share/zsh/zsh_history";
      };

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          "autojump"
          "git"
          "golang"
          "kubectl"
          "colored-man-pages"
          "ssh-agent"
          "zsh-interactive-cd"
          "history"
          "history-substring-search"
          "helm"
          "ansible"
          "z"
          "docker"
          "aws"
          "terraform"
          "fzf"
        ];
      };
      sessionVariables = { DEFAULT_USER = "roelc"; };
      shellAliases = {
        home = "cd ~/";
        gcl = "git clone";
        cat = "bat --paging=never";
        ls = "eza --icons --group-directories-first";
        ll = "eza --icons --group-directories-first -lah";
        grep = "rg";
        top = "btm";
        myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";
        nvim = "nix run ${home}/repos/nixos-config/templates/neovim";
      };
    };
  });
 
in
{
  programs.zsh.enable = true;
  dc-tec.core.zfs.systemCacheLinks = [ "/root/.local/share/autojump" ];
  dc-tec.core.zfs.homeCacheLinks = [ ".local/share/autojump" ];
  home-manager.users.roelc = { ... }: (base "/home/roelc");
  home-manager.users.root = { ... }: (base "/root");
}
