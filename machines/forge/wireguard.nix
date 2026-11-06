{ lib, pkgs, ... }:
let
  iptables = "${pkgs.iptables}/bin/iptables -w";
  workstation = "10.77.0.2";
  chad = "10.77.0.3";
  iphone = "10.77.0.4";
  lab = "10.79.0.0/22";
  relayJumps = [
    "-o wg0 -d ${lab}"
    "-o wg0 -d ${chad}"
    "-i wg0 -s ${lab}"
    "-i wg0 -s ${chad}"
  ];
  removeRelayJumps = lib.concatMapStrings (
    match: "${iptables} -D FORWARD ${match} -j forge-lab-relay 2>/dev/null || true\n"
  ) relayJumps;
  mobileJumps = [
    "-i wg0 -s ${iphone}"
    "-o wg0 -d ${iphone}"
  ];
  removeMobileRules = ''
    ${lib.concatMapStrings (
      match: "${iptables} -D FORWARD ${match} -j forge-t3-mobile 2>/dev/null || true\n"
    ) mobileJumps}
    ${iptables} -D INPUT -i wg0 -s ${iphone} -j DROP 2>/dev/null || true
  '';
in
{
  networking = {
    firewall = {
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ 51820 ];
      interfaces.wg0.allowedTCPPorts = [ 22 ];

      # Relay only workstation-initiated traffic to Chad and its lab networks.
      # Chad and lab guests can answer but cannot open connections through Forge.
      extraCommands = ''
        ${removeRelayJumps}
        ${iptables} -N forge-lab-relay 2>/dev/null || true
        ${iptables} -F forge-lab-relay
        ${iptables} -A forge-lab-relay -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        ${iptables} -A forge-lab-relay -i wg0 -o wg0 -s ${workstation} -j ACCEPT
        ${iptables} -A forge-lab-relay -j DROP
        ${lib.concatMapStrings (match: "${iptables} -I FORWARD ${match} -j forge-lab-relay\n") relayJumps}

        # Replace the mobile policy atomically without detaching existing jumps.
        ${iptables} -N forge-t3-mobile 2>/dev/null || true
        ${pkgs.iptables}/bin/iptables-restore -w --noflush <<'MOBILE_RULES'
        *filter
        -F forge-t3-mobile
        -A forge-t3-mobile -i wg0 -o wg0 -s ${iphone} -d ${workstation} -p tcp --dport 3773 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
        -A forge-t3-mobile -i wg0 -o wg0 -s ${workstation} -d ${iphone} -p tcp --sport 3773 -m conntrack --ctstate ESTABLISHED -j ACCEPT
        -A forge-t3-mobile -j DROP
        COMMIT
        MOBILE_RULES
        ${lib.concatMapStrings (match: ''
          ${iptables} -C FORWARD ${match} -j forge-t3-mobile 2>/dev/null || \
            ${iptables} -I FORWARD ${match} -j forge-t3-mobile
        '') mobileJumps}
        # The phone must not inherit the hub's WireGuard service permissions.
        ${iptables} -C INPUT -i wg0 -s ${iphone} -j DROP 2>/dev/null || \
          ${iptables} -I INPUT -i wg0 -s ${iphone} -j DROP
      '';
      extraStopCommands = removeRelayJumps + removeMobileRules;
    };

    wireguard.interfaces.wg0 = {
      ips = [ "10.77.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = "/var/lib/wireguard/forge.key";
      generatePrivateKeyFile = true;
      peers = [
        {
          # iPhone; forwarding and hub access are restricted above.
          publicKey = "Zwx19YlJukhneJL87HzRauDd1KGkkTiRd6R8fbJBED0=";
          allowedIPs = [ "${iphone}/32" ];
        }
        {
          # darwin administration workstation
          publicKey = "TlQaR99wrLOWDtXPBjLgL5Lifrdfn9CIsIQs1BEq7l8=";
          allowedIPs = [ "10.77.0.2/32" ];
        }
        {
          # chad lab host; routes the lab guest networks
          publicKey = "g0M9wOOFDUGLBW9eygfENuXH/vFSBYlU/Xb/eJUvNRw=";
          allowedIPs = [
            "${chad}/32"
            lab
          ];
        }
      ];
    };
  };

  systemd.tmpfiles.rules = [ "d /var/lib/wireguard 0700 root root -" ];
}
