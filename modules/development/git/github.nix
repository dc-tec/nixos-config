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
  dc-tec.core.zfs = lib.mkMerge [
    (lib.mkIf config.dc-tec.core.persistence.enable {
      homeCacheLinks = [".gh"];
    })
    (lib.mkIf (!config.dc-tec.core.persistence.enable) {})
  ];

  home-manager.users.roelc = {...}: (base "/home/roelc");
}
