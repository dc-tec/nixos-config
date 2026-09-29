{ lib, pkgs, ... }:
let
  iptables = "${pkgs.iptables}/bin/iptables -w";
  workstation = "10.77.0.2";
  chad = "10.77.0.3";
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
      '';
      extraStopCommands = removeRelayJumps;
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
