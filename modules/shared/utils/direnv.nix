{ config, lib, ... }:
{
  config = lib.mkMerge [
    (lib.mkIf config.dc-tec.isLinux {
      dc-tec.core.zfs = lib.mkMerge [
        (lib.mkIf config.dc-tec.persistence.enable {
          homeCacheLinks = [ ".local/share/direnv" ];
          systemCacheLinks = [ "/root/.local/share/direnv" ];
        })
      ];
    })
    {
      home-manager.users.${config.dc-tec.user.name} = {
        programs.direnv = {
          enable = true;
          enableZshIntegration = true;
          nix-direnv.enable = true;
        };
      };
    }
  ];
}
