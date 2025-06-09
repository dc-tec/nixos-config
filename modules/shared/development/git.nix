{ config, lib, ... }: {
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      programs.git = {
        enable = true;

        userEmail = if config.dc-tec.isDarwin then config.dc-tec.user.workEmail else config.dc-tec.user.email;
        userName = config.dc-tec.user.fullName;

        includes = [
          {
            path = "${config.dc-tec.user.homeDirectory}/projects/secretz/.gitconfig";
            condition = "gitdir:${config.dc-tec.user.homeDirectory}/projects/secretz/";
          }
        ];

        extraConfig = {
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          pull.rebase = true;
          core.sshCommand = "ssh -i ~/.ssh/roelc_gh";

          user.signingkey = "F95CABF0B7D54D8087FF9B3E321EAD1FC3C51961";
          commit.gpgsign = true;
          gpg.program = if config.dc-tec.isLinux then "${pkgs.gnupg}/bin/gpg2" else "/opt/homebrew/bin/gpg";
        };
      };
    };
  };
}