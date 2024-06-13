{
  config,
  pkgs,
  lib,
  ...
}: let
  base = home: {
    home.packages = [
      pkgs.autojump # jump to recent directory. ex "j nix"
      pkgs.comma # nix run shortcut. ex ", cowsay neato"
    ];

    programs.zsh = {
      enable = true;
      autosuggestion = {
        enable = true;
      };

      autocd = true;
      history = {
        expireDuplicatesFirst = true;
        path =
          if config.dc-tec.core.persistence.enable
          then "/data${home}/.local/share/zsh/zsh_history"
          else "${home}/.local/share/zsh/zsh_history";
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
        DEFAULT_USER = "roelc";
      };
      shellAliases = {
        home = "cd ~/";
        config = "cd ~/projects/personal/nixos-config";
        work = "cd ~/projects/work";
        personal = "cd ~/projects/personal";
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

        # Directory traversal
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        "......" = "cd ../../../../..";

        ## Neovim aliases
        vim = "nvim";
        vi = "nvim";

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
in {
  programs.zsh.enable = true;
  dc-tec.core.zfs = lib.mkMerge [
    (lib.mkIf config.dc-tec.core.persistence.enable {
      systemCacheLinks = ["/root/.local/share/autojump"];
      homeCacheLinks = [".local/share/autojump"];
    })
    (lib.mkIf (!config.dc-tec.core.persistence.enable) {})
  ];
  home-manager.users.roelc = _: (base "/home/roelc");
  home-manager.users.root = _: (base "/root");
}
