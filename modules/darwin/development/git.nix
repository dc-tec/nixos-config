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

    programs.lazygit = {
      enable = true;
      catppuccin.enable = true;
      settings = {
        git = {
          signOff = true;
        };
      };
    };
  };
}
