{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec = {
      development.virtualisation = {
        docker.enable = lib.mkEnableOption "docker";
      };
    };
  };

  config = lib.mkIf config.dc-tec.development.virtualisation.docker.enable {
    dc-tec.core.zfs.systemCacheLinks = ["/opt/docker"];

    virtualisation.docker = {
      enable = true;
      extraOptions = "--data-root ${config.dc-tec.dataPrefix}/var/lib/docker";
      storageDriver = "zfs";
    };

    home-manager.users.roelc = {
      home.packages = with pkgs; [
        docker-compose
      ];
    };
    users.users.roelc.extraGroups = ["docker"];
  };
}
