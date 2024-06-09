{config, ...}: {
  dc-tec = {
    core = {
      zfs = {
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
      };
    };
  };

  # TODO: Configure SSH Agent
  home-manager.users.roelc = _: {
    programs.ssh = {
      enable = true;
      hashKnownHosts = true;
      userKnownHostsFile =
        if config.dc-tec.core.persistence.enable
        then "${config.dc-tec.dataPrefix}/home/roelc/.ssh/known_hosts"
        else "/home/roelc/.ssh/known_hosts";
      extraOptionOverrides = {
        AddKeysToAgent = "yes";
        IdentityFile =
          if config.dc-tec.core.persistence.enable
          then "${config.dc-tec.dataPrefix}/home/roelc/.ssh/id_ed25519"
          else "/home/roelc/.ssh/id_ed25519";
      };
    };

    services = {
      ssh-agent = {
        enable = true;
      };
    };
  };
}
