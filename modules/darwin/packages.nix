{
  config,
  outputs,
  pkgs,
  ...
}:
{
  programs.mas = {
    enable = true;
    packages.WireGuard = 1451685025;
  };

  home-manager.users.${config.dc-tec.user.name}.home.packages = with pkgs; [
    outputs.packages.${pkgs.stdenv.hostPlatform.system}.forge-tools
    radicle-node
    radicle-tui
  ];
}
