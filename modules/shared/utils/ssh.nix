{
  config,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf config.dc-tec.isLinux {
      dc-tec.core.zfs = lib.mkMerge [
        (lib.mkIf config.dc-tec.persistence.enable {
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
      ];
    })
    {
      home-manager.users.${config.dc-tec.user.name} = lib.mkMerge [
        # Main SSH configuration (applies to all systems)
        {
          programs.ssh = {
            enable = true;
            hashKnownHosts = true;
            userKnownHostsFile =
              if config.dc-tec.persistence.enable && config.dc-tec.isLinux then
                "${config.dc-tec.persistence.dataPrefix}/home/${config.dc-tec.user.name}/.ssh/known_hosts"
              else
                "${config.dc-tec.user.homeDirectory}/.ssh/known_hosts";
            extraOptionOverrides = {
              AddKeysToAgent = "yes";
              IdentityFile =
                if config.dc-tec.persistence.enable && config.dc-tec.isLinux then
                  "${config.dc-tec.persistence.dataPrefix}/home/${config.dc-tec.user.name}/.ssh/id_ed25519"
                else
                  "${config.dc-tec.user.homeDirectory}/.ssh/id_ed25519";
            };
            extraConfig = lib.mkIf config.dc-tec.isDarwin ''
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
        }
        # Enable the ssh-agent service only on Linux machines.
        (lib.mkIf config.dc-tec.isLinux {
          services.ssh-agent = {
            enable = true;
          };
        })
      ];
    }
  ];
}
