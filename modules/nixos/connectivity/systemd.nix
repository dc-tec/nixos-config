_: {
  systemd.services."enable-wifi-on-boot" = {
    description = "Enable Wifi during boot";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "/run/current-system/sw/bin/rfkill unblock all";
      Type = "oneshot";
    };
  };
}
