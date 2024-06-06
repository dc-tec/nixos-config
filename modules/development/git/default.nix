{
  config,
  lib,
  ...
}: {
  imports = [
    ./lazy_git.nix
    ./github.nix
  ];

  options.dc-tec.development.git = {
    enable = lib.mkOption {
      default = true;
      example = false;
    };
    email = lib.mkOption {
      default = "roel@decort.tech";
      example = "example@example.com";
    };
  };

  config = let
    base = {
      programs.git = {
        enable = true;

        userEmail = config.dc-tec.development.git.email;
        userName = "Roel de Cort";

        includes = [
          {
            path = "/home/roelc/work/.gitconfig";
            condition = "gitdir:/home/roelc/work/";
          }
        ];

        extraConfig = {
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          pull.rebase = true;

          url = {
            "ssh://git@github.com/dc-tec" = {
              insteadOf = "https://github.com/dc-tec";
            };
          };

          github.user = "dc-tec";
          safe.directory = "/home/roelc/repos/nixos-config/.git";
        };
      };
    };
  in {
    home-manager.users.roelc = {...}: base;
    home-manager.users.root = {...}: base;
  };
}
