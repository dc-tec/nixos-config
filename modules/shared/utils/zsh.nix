{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.dc-tec.isLinux {
    dc-tec.core.zfs = lib.mkMerge [
      (lib.mkIf config.dc-tec.core.persistence.enable {
        systemCacheLinks = [ "/root/.local/share/autojump" ];
        homeCacheLinks = [ ".local/share/autojump" ];
      })
      (lib.mkIf (!config.dc-tec.core.persistence.enable) { })
    ];

    programs.zsh.enable = true;

    home-manager.users.${config.dc-tec.user.name} = {
      programs.zsh = {
        enable = true;
        autosuggestion = {
          enable = true;
        };

        # https://github.com/catppuccin/zsh-syntax-highlighting/blob/main/themes/catppuccin_macchiato-zsh-syntax-highlighting.zsh

        syntaxHighlighting = {
          enable = true;
          highlighters = [
            "main"
            "cursor"
          ];
          styles = {
            comment = "fg=#5b6078";
            alias = "fg=#a6da95";
            suffix-alias = "fg=#a6da95";
            global-alias = "fg=#a6da95";
            function = "fg=#a6da95";
            command = "fg=#a6da95";
            precommand = "fg=#a6da95,italic";
            autodirectory = "fg=#f5a97f,italic";
            single-hyphen-option = "fg=#f5a97f";
            double-hyphen-option = "fg=#f5a97f";
            back-quoted-argument = "fg=#c6a0f6";
            builtin = "fg=#a6da95";
            reserved-word = "fg=#a6da95";
            hashed-command = "fg=#a6da95";
            commandseparator = "fg=#ed8796";
            command-substitution-delimiter = "fg=#cad3f5";
            command-substitution-delimiter-unquoted = "fg=#cad3f5";
            process-substitution-delimiter = "fg=#cad3f5";
            back-quoted-argument-delimiter = "fg=#ed8796";
            back-double-quoted-argument = "fg=#ed8796";
            back-dollar-quoted-argument = "fg=#ed8796";
            command-substitution-quoted = "fg=#eed49f";
            command-substitution-delimiter-quoted = "fg=#eed49f";
            single-quoted-argument = "fg=#eed49f";
            single-quoted-argument-unclosed = "fg=#ee99a0";
            double-quoted-argument = "fg=#eed49f";
            double-quoted-argument-unclosed = "fg=#ee99a0";
            rc-quote = "fg=#eed49f";
            dollar-quoted-argument = "fg=#cad3f5";
            dollar-quoted-argument-unclosed = "fg=#ee99a0";
            dollar-double-quoted-argument = "fg=#cad3f5";
            assign = "fg=#cad3f5";
            named-fd = "fg=#cad3f5";
            numeric-fd = "fg=#cad3f5";
            unknown-token = "fg=#ee99a0";
            path = "fg=#cad3f5,underline";
            path_pathseparator = "fg=#ed8796,underline";
            path_prefix = "fg=#cad3f5,underline";
            path_prefix_pathseparator = "fg=#ed8796,underline";
            globbing = "fg=#cad3f5";
            history-expansion = "fg=#c6a0f6";
            back-quoted-argument-unclosed = "fg=#ee99a0";
            redirection = "fg=#cad3f5";
            arg0 = "fg=#cad3f5";
            default = "fg=#cad3f5";
            cursor = "fg=#cad3f5";
          };
        };

        autocd = true;
        history = {
          expireDuplicatesFirst = true;
          path =
            if config.dc-tec.core.persistence.enable then
              "${config.dc-tec.dataPrefix}/home/${config.dc-tec.user.name}/.local/share/zsh/zsh_history"
            else
              "${config.dc-tec.user.homeDirectory}/.local/share/zsh/zsh_history";
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
            "zsh-interactive-cd"
            "history"
            "history-substring-search"
            "helm"
            "ansible"
            "docker"
            "aws"
            "terraform"
          ];
        };
        sessionVariables = {
          DEFAULT_USER = config.dc-tec.user.name;
          PATH =
            if config.dc-tec.isDarwin then
              "/opt/homebrew/bin:/Users/${config.dc-tec.user.name}/Library/Python/3.9/bin:$PATH"
            else
              "$PATH";
          GPG_TTY = ''$(tty)'';
        };
        shellAliases = {
          home = "cd ~/";
          config = "cd ~/projects/personal/nixos-config";
          work = "cd ~/projects/work";
          personal = "cd ~/projects/personal";
          secretz = "cd ~/projects/secretz";
          gcl = "git clone";
          cat = "bat --paging=never";
          ls = "eza --icons --group-directories-first";
          man = "tlrc";
          ll = "eza --icons --group-directories-first -lah";
          grep = "rg";
          top = "btm";
          cls = "clear";
          myip = "dig +short myip.opendns.com @208.67.222.222 2>&1";
          lg = "lazygit";
          find = "fd";

          # Directory traversal
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";
          "....." = "cd ../../../..";
          "......" = "cd ../../../../..";

          ## Neovim aliases
          vim = "nvim";
          vi = "nvim";
          v = "nvim";

          # Kubernetes aliases
          k = "kubectl";
          ka = "kubectl apply -f";
          kak = "kubectl apply -k";
          kg = "kubectl get";
          kd = "kubectl describe";
          kdel = "kubectl delete";
          kl = "kubectl logs";
          kgp = "kubectl get pods";
          kgd = "kubectl get deployments";
          ke = "kubectl exec -it";
          kcsns = "kubectl config set-context --current --namespace";

          # Terraform aliases
          t = "terraform";
          ta = "terraform apply";
          tp = "terraform plan";
          td = "terraform destroy";
          tinit = "terraform init";
          tup = "terraform init -upgrade";

          # Ansible aliases
          a = "ansible";
          ap = "ansible-playbook";

          # Docker aliases
          d = "docker";
          dps = "docker ps";
          dpsa = "docker ps -a";
          di = "docker images";
          ds = "docker stop";
          drm = "docker rm";

          # Helm aliases
          h = "helm";
          hi = "helm install";
          hu = "helm upgrade";
        };
      };
    };
  };
}
