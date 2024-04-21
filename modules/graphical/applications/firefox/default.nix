{
  config,
  lib,
  ...
}: {
  options.dc-tec.graphical.applications.firefox.enable = lib.mkEnableOption "firefox";

  config = lib.mkIf config.dc-tec.graphical.applications.firefox.enable {
    dc-tec.core.zfs.homeCacheLinks = [".mozilla"];

    home-manager.users.roelc = {pkgs, ...}: {
      programs.firefox = {
        enable = true;
        profiles.dc-tec = {
          bookmarks = {};
        };
      };
    };
  };
}
