{
  pkgs,
  lib,
  config,
  ...
}: {
  options = {
    dc-tec.development = {
      docker.enable = lib.mkEnableOption "docker";
    };
  };

  config = lib.mkIf config.dc-tec.development.docker.enable {
    virtualization.docker = {
      enable = true;
      extraOptions = "${config.dc-tec.dataPrefix}/var/lib/docker";
      storageDriver = "zfs";
    };

    home-managers.users.roelc = {
      home.packages = with pkgs; [
        docker-compose
      ];
    };
    users.users.roelc.extraGroups = ["docker"];
  };
}
