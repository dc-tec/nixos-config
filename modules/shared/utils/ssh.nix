{
  config,
  lib,
  ...
}:
{
  config = {
    dc-tec.core.zfs = lib.mkMerge [
      (lib.mkIf config.dc-tec.core.persistence.enable {
        homeDataLinks = [
          {
            directory = ".ssh";
            mode = "0700";
          }
        ];
        systemDataLinks = [
          {
            directory = "/root/.ssh/";
            mode = "0700";
          }
        ];
      })
      (lib.mkIf (!config.dc-tec.core.persistence.enable) { })
    ];

    home-manager.users.${config.dc-tec.user.name} = {
      services.ssh-agent = {
        enable = true;
      };

      programs.ssh = {
        enable = true;
        hashKnownHosts = true;
        userKnownHostsFile =
          if config.dc-tec.core.persistence.enable && lib.dc-tec.isLinux
          then "${config.dc-tec.dataPrefix}/home/${config.dc-tec.user.name}/.ssh/known_hosts"
          else "${config.dc-tec.user.homeDirectory}/.ssh/known_hosts";
        extraOptionOverrides = {
          AddKeysToAgent = "yes";
          IdentityFile =
            if config.dc-tec.core.persistence.enable && lib.dc-tec.isLinux
            then "${config.dc-tec.dataPrefix}/home/${config.dc-tec.user.name}/.ssh/id_ed25519"
            else "${config.dc-tec.user.homeDirectory}/.ssh/id_ed25519";
        };
        extraConfig = lib.mkIf lib.dc-tec.isDarwin ''
          UseKeychain yes
          IdentityFile ~/.ssh/roelc_gh
        '';

        matchBlocks = {
          "adfinis-gitlab" = {
            hostname = "git.adfinis.com";
            user = "git";
            forwardAgent = true;
            identitiesOnly = true;
            identityFile = "~/.ssh/id_ed25519";
          };
          "github" = {
            hostname = "github.com";
            user = "git";
            forwardAgent = true;
            identitiesOnly = true;
            identityFile = "~/.ssh/roelc_gh";
          };
          "gitlab" = {
            hostname = "gitlab.com";
            forwardAgent = true;
            identitiesOnly = true;
            user = "git";
            identityFile = "~/.ssh/roelc_gh";
          };
          "chad" = {
            hostname = "10.0.10.183";
            user = "roelc";
            forwardAgent = true;
            identityFile = "~/.ssh/roelc_gh";
          };
          "ssh.decort.tech" = {
            hostname = "ssh.decort.tech";
            user = "roelc";
            identityFile = "~/.ssh/roelc_gh";
            proxyCommand = "/opt/homebrew/bin/cloudflared access ssh --hostname %h";
          };
          "adfinis-openwebui" = {
            hostname = "91.99.78.1";
            user = "root";
            identityFile = "~/.ssh/id_ed25519";
          };
        };
      };
    };
  };
}
