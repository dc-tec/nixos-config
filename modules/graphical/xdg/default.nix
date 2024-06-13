{
  config,
  lib,
  pkgs,
  ...
}: {
  options.dc-tec.graphical.xdg.enable = lib.mkEnableOption "xdg folders";

  config = lib.mkIf config.dc-tec.graphical.xdg.enable {
    dc-tec.core.zfs.homeDataLinks = ["documents" "music" "pictures" "videos"];
    dc-tec.core.zfs.homeCacheLinks = ["downloads" "projects"];

    xdg = {
      portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = with pkgs; [xdg-desktop-portal-hyprland];
        configPackages = with pkgs; [xdg-desktop-portal-hyprland];
      };
    };

    home-manager.users.roelc = {pkgs, ...}: {
      home.packages = with pkgs; [xdg-user-dirs xdg-utils];
      xdg = {
        enable = true;
        userDirs = {
          enable = true;
          desktop = "$HOME/desktop";
          documents = "$HOME/documents";
          download = "$HOME/downloads";
          music = "$HOME/music";
          pictures = "$HOME/pictures";
          publicShare = "$HOME/desktop";
          templates = "$HOME/templates";
          videos = "$HOME/videos";
        };
      };
    };
  };
}
