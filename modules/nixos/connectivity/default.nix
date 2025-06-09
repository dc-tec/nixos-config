{...}: {
  imports = [
    ./systemd.nix
    ./wireless.nix
    ./cloudflared.nix
  ];
}
