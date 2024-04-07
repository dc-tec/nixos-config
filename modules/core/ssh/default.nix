{ config, lib, pkgs, ... }: 
let
  base = home: user: { 
    programs.ssh = {
      enable = true;
      hashKnownHosts = true;
      userKnownHostsFile = "${config.dc-tec.cachePrefix}${home}/.ssh/known_hosts";
      extraOptionOverrides = {
        IdentityFile = "${config.dc-tec.dataPrefix}${home}/.ssh/id_ed25519"; 
      };
    };
  };
  in
  {
  home-manager.users.root = { ... }: (base "/root" "root");
  home-manager.users.roelc = { ... }: (base "/home/roelc" "roelc");    
  }

