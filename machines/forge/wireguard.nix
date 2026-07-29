_: {
  networking = {
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ 51820 ];
      interfaces.wg0.allowedTCPPorts = [ 22 ];
    };

    wireguard.interfaces.wg0 = {
      ips = [ "10.77.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = "/var/lib/wireguard/forge.key";
      generatePrivateKeyFile = true;
      peers = [
        {
          # darwin administration workstation
          publicKey = "TlQaR99wrLOWDtXPBjLgL5Lifrdfn9CIsIQs1BEq7l8=";
          allowedIPs = [ "10.77.0.2/32" ];
        }
      ];
    };
  };

  systemd.tmpfiles.rules = [ "d /var/lib/wireguard 0700 root root -" ];
}
