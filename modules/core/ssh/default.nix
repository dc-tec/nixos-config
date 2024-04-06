{ config, lib, pkgs, ... }: {

#  dc-tec.core.zfs.homeDataLinks = [{
#    directory = ".ssh";
#    mode = "0700";
#  }];

  home-manager.users.roelc = { ... }: { 
    programs.ssh.enable = true; 
  };

  dc-tec.core.zfs.systemDataLinks = [{
    directory = "/root/.ssh";
    mode = "0700";
  }];
}
