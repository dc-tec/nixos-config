{ config, lib, ... }:
{
  options.dc-tec.core.direnv = lib.mkMerge [
    (
      lib.mkIf config.dc-tec.persistence.enable
      && config.dc-tec.isLinux {
        homeCacheLinks = [ "local/share/direnv" ];
        systemCacheLinks = [ "/root/.local/share/direnv" ];
      }
    )
    (lib.mkIf (!config.dc-tec.persistence.enable && config.dc-tec.isLinux) { })
  ];

  config = {
    home-manager.users.${config.dc-tec.user.name} = {
      programs.direnv = {
        enable = true;
        enableZshIntegration = true;
        nix-direnv.enable = true;
      };
    };
  };
}
