{ config, lib, pkgs ... }: {
  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      programs.git = {
        enable = true;

        # Primary email: work on Darwin, personal on Linux
        userEmail = if config.dc-tec.isDarwin then config.dc-tec.user.workEmail else config.dc-tec.user.email;
        userName = config.dc-tec.user.fullName;

        includes = lib.flatten [
          # Always include secretz configuration on both platforms
          {
            condition = "gitdir:${config.dc-tec.user.homeDirectory}/projects/secretz/";
            contents = {
              user = {
                name = config.dc-tec.user.fullName;
                email = "roel.decort@secretz.io";
                signingKey = config.dc-tec.user.gpgKey;
              };
              commit.gpgSign = true;
              core.sshCommand = if config.dc-tec.isLinux then "ssh -i ~/.ssh/id_ed25519" else "ssh -i ~/.ssh/roelc_gh";
              gpg.program = if config.dc-tec.isLinux then "${pkgs.gnupg}/bin/gpg2" else "/opt/homebrew/bin/gpg";
            };
          }
          
          # Darwin (work primary): override for personal projects
          (lib.optionals config.dc-tec.isDarwin [
            {
              condition = "gitdir:${config.dc-tec.user.homeDirectory}/projects/personal/";
              contents = {
                user = {
                  name = config.dc-tec.user.fullName;
                  email = config.dc-tec.user.email;
                  signingKey = config.dc-tec.user.gpgKey;
                };
                commit.gpgSign = true;
                core.sshCommand = "ssh -i ~/.ssh/roelc_gh";
                gpg.program = "/opt/homebrew/bin/gpg";
              };
            }
          ])
          
          # Linux (personal primary): override for work projects
          (lib.optionals config.dc-tec.isLinux [
            {
              condition = "gitdir:${config.dc-tec.user.homeDirectory}/projects/work/";
              contents = {
                user = {
                  name = config.dc-tec.user.fullName;
                  email = config.dc-tec.user.workEmail;
                  signingKey = config.dc-tec.user.gpgKey;
                };
                commit.gpgSign = true;
                core.sshCommand = "ssh -i ~/.ssh/id_ed25519";
                gpg.program = "${pkgs.gnupg}/bin/gpg2";
              };
            }
          ])
        ];

        # Primary configuration (work on Darwin, personal on Linux)
        extraConfig = {
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          pull.rebase = true;
          core.sshCommand = if config.dc-tec.isLinux then "ssh -i ~/.ssh/id_ed25519" else "ssh -i ~/.ssh/roelc_gh";

          safe.directory = "${config.dc-tec.user.homeDirectory}/projects/personal/nixos-config";

          user.signingkey = config.dc-tec.user.gpgKey;
          commit.gpgsign = true;
          gpg.program = if config.dc-tec.isLinux then "${pkgs.gnupg}/bin/gpg2" else "/opt/homebrew/bin/gpg";
        };
      };
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

    programs.gh = {
      enable = true;
      settings = {
        editor = "nvim";
        git_protocol = "ssh";
      };
    };
  };
}
