{
  config,
  pkgs,
  ...
}:
{
  programs.mas = {
    enable = true;
    packages.WireGuard = 1451685025;
  };

  home-manager.users.${config.dc-tec.user.name}.home.packages = with pkgs; [
    radicle-node
    radicle-tui
  ];
}
