{ config, lib, pkgs, ... }: { 
  
  dc-tec.core.zfs.homeDataLinks = [{
    directory = ".ssh";
    mode = "0700";
  }];

  dc-tec.core.zfs.systemDataLinks = [{
    directory = "/root/.ssh/";
    mode = "0700";
  }];

  # TODO: Configure SSH Agent
  home-manager.users.roelc = { ... }: {
    programs.ssh = {
      enable = true;
      hashKnownHosts = true;
      userKnownHostsFile = "${config.dc-tec.dataPrefix}/home/roelc/.ssh/known_hosts";
      extraOptionOverrides = {
        IdentityFile = "${config.dc-tec.dataPrefix}/home/roelc/.ssh/id_ed25519"; 
      };
    };
  };
}