{ lib, pkgs, ... }:
let
  iptables = "${pkgs.iptables}/bin/iptables -w";
  workstation = "10.77.0.2";
  tunnelAddress = "10.77.0.3";
  # Lab guest networks; libvirt defines them in `open` forward mode so that
  # this firewall, not libvirt, owns their forwarding policy.
  lab = "10.79.0.0/22";
  labPorts = "22,443,5000,6443,8200,8443,50000";
  forwardJumps = [
    "-i wg0"
    "-o wg0"
    "-s ${lab}"
    "-d ${lab}"
  ];
  removeJumps = ''
    ${lib.concatMapStrings (
      match: "${iptables} -D FORWARD ${match} -j chad-lab-forward 2>/dev/null || true\n"
    ) forwardJumps}
    ${iptables} -t nat -D POSTROUTING -j chad-lab-nat 2>/dev/null || true
  '';
in
{
  networking = {
    wireguard.interfaces.wg0 = {
      ips = [ "${tunnelAddress}/24" ];
      privateKeyFile = "/var/lib/wireguard/chad.key";
      generatePrivateKeyFile = true;
      peers = [
        {
          # Forge hub; Chad dials out so the home network needs no inbound port.
          publicKey = "bkf+oPNj3mK7i9P5DalNs3f3ez2wFPagned7K+ePYgo=";
          endpoint = "vpn.decort.tech:51820";
          allowedIPs = [ "10.77.0.0/24" ];
          persistentKeepalive = 25;
          dynamicEndpointRefreshSeconds = 300;
        }
      ];
    };

    firewall = {
      extraCommands = ''
        # Administration from the workstation peer only; the hub's own address
        # cannot open connections to Chad or the lab.
        ${iptables} -A nixos-fw -i wg0 -s ${workstation} -p tcp --dport 22 -j nixos-fw-accept
        ${iptables} -A nixos-fw -i wg0 -s ${workstation} -d ${tunnelAddress} -p udp --dport 53 -j nixos-fw-accept
        ${iptables} -A nixos-fw -i wg0 -s ${workstation} -d ${tunnelAddress} -p tcp --dport 53 -j nixos-fw-accept
        # Libvirt adds no rules for open networks; their bridges are named lab-*.
        ${iptables} -A nixos-fw -i lab+ -p udp -m multiport --dports 53,67 -j nixos-fw-accept
        ${iptables} -A nixos-fw -i lab+ -p tcp --dport 53 -j nixos-fw-accept

        ${removeJumps}
        ${iptables} -N chad-lab-forward 2>/dev/null || true
        ${iptables} -F chad-lab-forward
        ${iptables} -A chad-lab-forward -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        # KeyHub PoC appliance manager; only the workstation may reach it.
        ${iptables} -A chad-lab-forward -i wg0 -s ${workstation} -d 10.79.3.50 -p tcp --dport 50443 -j ACCEPT
        ${iptables} -A chad-lab-forward -i wg0 -s ${workstation} -d ${lab} -p tcp -m multiport --dports ${labPorts} -j ACCEPT
        ${iptables} -A chad-lab-forward -s ${lab} -d ${lab} -j ACCEPT
        ${iptables} -A chad-lab-forward -s ${lab} -o br0 -d 10.0.0.0/8 -j DROP
        ${iptables} -A chad-lab-forward -s ${lab} -o br0 -d 172.16.0.0/12 -j DROP
        ${iptables} -A chad-lab-forward -s ${lab} -o br0 -d 192.168.0.0/16 -j DROP
        ${iptables} -A chad-lab-forward -s ${lab} -o br0 -j ACCEPT
        ${iptables} -A chad-lab-forward -j DROP
        # Appended after libvirt's own chains, which keep handling NAT networks.
        ${lib.concatMapStrings (
          match: "${iptables} -A FORWARD ${match} -j chad-lab-forward\n"
        ) forwardJumps}

        ${iptables} -t nat -N chad-lab-nat 2>/dev/null || true
        ${iptables} -t nat -F chad-lab-nat
        ${iptables} -t nat -A chad-lab-nat -s ${lab} ! -d ${lab} -o br0 -j MASQUERADE
        ${iptables} -t nat -A POSTROUTING -j chad-lab-nat
      '';
      extraStopCommands = removeJumps;
    };
  };

  # Libvirt's per-network resolvers answer only queries arriving on their own
  # bridge. This resolver serves the lab zone to the workstation over the
  # tunnel; the foundation network resolver forwards the sibling subdomains.
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;
    settings = {
      listen-address = tunnelAddress;
      bind-dynamic = true;
      no-resolv = true;
      no-hosts = true;
      server = [ "/lab.decort.tech/10.79.0.1" ];
    };
  };

  systemd.tmpfiles.rules = [ "d /var/lib/wireguard 0700 root root -" ];
}
