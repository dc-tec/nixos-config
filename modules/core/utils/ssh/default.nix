{config, ...}: {
  dc-tec.core.zfs.homeDataLinks = [
    {
      directory = ".ssh";
      mode = "0700";
    }
  ];

  dc-tec.core.zfs.systemDataLinks = [
    {
      directory = "/root/.ssh/";
      mode = "0700";
    }
  ];

  # TODO: Configure SSH Agent
  home-manager.users.roelc = {...}: {
    programs.ssh = {
      enable = true;
      hashKnownHosts = true;
      userKnownHostsFile = "${config.dc-tec.dataPrefix}/home/roelc/.ssh/known_hosts";
      extraOptionOverrides = {
        AddKeysToAgent = "yes";
        IdentityFile = "${config.dc-tec.dataPrefix}/home/roelc/.ssh/id_ed25519";
      };
    };

    services = {
      ssh-agent = {
        enable = true;
      };
    };
  };

  systemd.services."Ensure SSH Agent" = {
    description = "Ensure SSH Agent is running";
    wantedBy = ["default.target"];
    serviceConfig = {
      Environment = ["SSH_AUTH_SOCK=%t/ssh-agent.socket" "DISPLAY=:0"];
      ExecStart = "/run/current-system/sw/bin/ssh-agent -D -a $SSH_AUTH_SOCK";
      Type = "simple";
    };
  };
}
