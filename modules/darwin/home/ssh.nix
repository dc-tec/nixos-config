{ ... }:
{
  home-manager.users.roelc = _: {
    programs.ssh = {
      enable = true;
      hashKnownHosts = true;
      userKnownHostsFile = "~/.ssh/known_hosts";
      addKeysToAgent = "yes";
      extraConfig = ''
        UseKeychain yes
        IdentityFile ~/.ssh/id_ed25519
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
}
