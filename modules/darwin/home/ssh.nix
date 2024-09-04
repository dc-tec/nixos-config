{...}: {
  home-manager.users.roelc = _: {
    programs.ssh = {
      enable = true;
      hashKnownHosts = true;
      userKnownHostsFile = "~/.ssh/known_hosts";

      extraConfig = ''
        AddKeysToAgent yes
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
          hostname = "10.0.1.125";
          user = "roelc";
          forwardAgent = true;
          identityFile = "~/.ssh/roelc_gh";
        };
      };
    };
  };
}
