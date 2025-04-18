{ ... }:
{
  home-manager.users.roelc = {
    programs.git = {
      enable = true;

      userEmail = "roel.decort@adfinis.com";
      userName = "Roel de Cort";

      includes = [
        {
          path = "~/projects/personal/.gitconfig";
          condition = "gitdir:~/projects/personal/";
        }
        {
          path = "~/projects/secretz/.gitconfig";
          condition = "gitdir:~/projects/secretz/";
        }
      ];

      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        pull.rebase = true;
        core.sshCommand = "ssh -i ~/.ssh/id_ed25519";
      };
    };

    ## Personal gitconfig
    home.file."./projects/personal/.gitconfig" = {
      source = ./.gitconfig;
      recursive = true;
    };

    ## Secretz gitconfig
    home.file."./projects/secretz/.gitconfig" = {
      source = ./.gitconfig-secretz;
      recursive = true;
    };

    catppuccin.lazygit.enable = true;
    programs.lazygit = {
      enable = true;
      settings = {
        git = {
          commit = {
            signOff = true;
          };
        };
      };
    };
  };
}
