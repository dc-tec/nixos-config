{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./lazy_git.nix
    ./github.nix
  ];

  options.dc-tec.development.git = {
    enable = lib.mkOption {
      default = true;
    };
    email = lib.mkOption {
      default = "roel@decort.tech";
    };
  };

  config =
    let
      base = {
        programs.git = {
          enable = true;

          userEmail = config.dc-tec.development.git.email;
          userName = "Roel de Cort";

          includes = [
            {
              path = "/home/roelc/projects/work/.gitconfig";
              condition = "gitdir:/home/roelc/projects/work/";
            }
          ];

          extraConfig = {
            init.defaultBranch = "main";
            push.autoSetupRemote = true;
            pull.rebase = true;

            user.signingkey = "5C04F622E4FD914D5E2AF671DED0E794E70C0F7F";
            commit.gpgsign = true;
            gpg.program = "${pkgs.gnupg}/bin/gpg2";

            url = {
              "ssh://git@github.com/dc-tec" = {
                insteadOf = "https://github.com/dc-tec";
              };
            };

            github.user = "dc-tec";
            safe.directory = "/home/roelc/projects/personal/github/nixos-config";
          };
        };
      };
    in
    {
      home-manager.users.roelc = { ... }: base;
      home-manager.users.root = { ... }: base;
    };
}
