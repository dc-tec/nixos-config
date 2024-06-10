_: {
  systemd.services."enable-wsl-vpnkit" = {
    description = "Enable wsl vpnkit";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "/mnt/c/Windows/system32/wsl.exe -d wsl-vpnkit --cd /app wsl-vpnkit";
      Restart = "always";
      KillMode = "mixed";
    };
  };
}
