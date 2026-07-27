{
  config,
  pkgs,
  ...
}:
{
  home-manager.users.${config.dc-tec.user.name}.home.packages = with pkgs; [
    radicle-node
    radicle-tui
  ];
}
