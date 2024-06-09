{pkgs, ...}: {
  imports = [
    ./starship
    ./zsh
  ];

  users = {
    defaultUserShell = pkgs.zsh;
  };
}
