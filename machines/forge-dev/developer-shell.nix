{
  inputs,
  pkgs,
  ...
}:
let
  starshipConfig = (pkgs.formats.toml { }).generate "forge-dev-starship.toml" {
    add_newline = false;
    command_timeout = 1000;
    format = "$directory$git_branch$git_status$direnv$cmd_duration\n$character";
    right_format = "$hostname";

    character = {
      success_symbol = "[󱄅 ❯](bold green)";
      error_symbol = "[󱄅 ❯](bold red)";
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

    git_branch = {
      always_show_remote = true;
      format = "on [$symbol$branch(:$remote_name/$remote_branch)]($style) ";
      symbol = " ";
    };

    hostname = {
      ssh_symbol = " ";
      format = "connected to [$ssh_symbol$hostname]($style) ";
    };
  };
in
{
  users.users.dev.shell = pkgs.zsh;

  # Suppress zsh's first-run wizard without owning future user customizations.
  # The shared shell configuration is loaded from /etc/zshrc; tmpfiles only
  # creates this file when it does not exist.
  systemd.tmpfiles.rules = [
    "f /srv/dev/home/dev/.zshrc 0644 dev users -"
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestions.enable = true;
    syntaxHighlighting = {
      enable = true;
      highlighters = [
        "main"
        "brackets"
        "cursor"
      ];
    };

    histSize = 100000;
    setOptions = [
      "AUTO_CD"
      "HIST_EXPIRE_DUPS_FIRST"
      "HIST_FCNTL_LOCK"
      "HIST_IGNORE_ALL_DUPS"
      "HIST_REDUCE_BLANKS"
      "SHARE_HISTORY"
    ];

    ohMyZsh = {
      enable = true;
      plugins = [
        "colored-man-pages"
        "docker"
        "git"
        "helm"
        "history"
        "history-substring-search"
        "kubectl"
        "zsh-interactive-cd"
      ];
      theme = "";
    };

    interactiveShellInit = ''
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      eval "$(${pkgs.fzf}/bin/fzf --zsh)"
      eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"

      yy() {
        local yazi_cwd yazi_tmp
        yazi_tmp="$(${pkgs.coreutils}/bin/mktemp --tmpdir yazi-cwd.XXXXXX)" || return
        ${pkgs.yazi}/bin/yazi "$@" --cwd-file="$yazi_tmp"
        IFS= read -r yazi_cwd < "$yazi_tmp"
        if [[ -n "$yazi_cwd" && "$yazi_cwd" != "$PWD" ]]; then
          builtin cd -- "$yazi_cwd"
        fi
        ${pkgs.coreutils}/bin/rm -f -- "$yazi_tmp"
      }
    '';

    promptInit = ''
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    '';

    shellAliases = {
      home = "cd ~/";
      config = "cd ~/projects/personal/nixos-config";
      work = "cd ~/projects/work";
      personal = "cd ~/projects/personal";
      secretz = "cd ~/projects/secretz";

      gcl = "git clone";
      cat = "bat --paging=never";
      ls = "eza --icons --group-directories-first";
      ll = "eza --icons --group-directories-first -lah";
      grep = "rg";
      find = "fd";
      top = "btm";
      lg = "lazygit";
      cls = "clear";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";

      vim = "nvim";
      vi = "nvim";
      v = "nvim";

      k = "kubectl";
      kg = "kubectl get";
      kd = "kubectl describe";
      kl = "kubectl logs";
      kgp = "kubectl get pods";

      d = "docker";
      dps = "docker ps";
      dpsa = "docker ps -a";
      di = "docker images";
      dexec = "docker exec";

      h = "helm";
      hi = "helm install";
      hu = "helm upgrade";
    };
  };

  environment = {
    sessionVariables = {
      BAT_PAGER = "less -RF";
      EDITOR = "nvim";
      LESS = "-FRX";
      PAGER = "less";
      STARSHIP_CONFIG = starshipConfig;
      VISUAL = "nvim";
    };

    systemPackages = with pkgs; [
      atac
      bat
      comma
      dnsutils
      eza
      fzf
      jujutsu
      lazygit
      moreutils
      inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
      starship
      tlrc
      tree
      unzip
      wget
      whois
      yazi
      yq
      zoxide
    ];
  };
}
