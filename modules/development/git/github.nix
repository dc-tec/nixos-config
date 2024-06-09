{
  lib,
  config,
  ...
}: let
  base = home: {
    programs.gh = {
      enable = true;
      settings = {
        editor = "nvim";
        git_protocol = "ssh";
      };
    };
  };
in {
  dc-tec.core.zfs.homeCacheLinks = lib.mkIf config.dc-tec.core.persistence.enable [".gh"];
  home-manager.users.roelc = {...}: (base "/home/roelc");
}
