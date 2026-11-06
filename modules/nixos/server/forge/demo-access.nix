{ lib, pkgs, ... }:
let
  proxies = {
    gateway = {
      description = "Kubernetes Gateway";
      port = 8443;
      target = "10.78.0.10:28443";
    };
    api = {
      description = "Kubernetes API";
      port = 28643;
      target = "10.78.0.10:28643";
    };
  };
in
{
  # The remaining WireGuard peers must not inherit demo administrator access.
  networking.firewall.extraCommands = lib.concatMapStrings (proxy: ''
    ${pkgs.iptables}/bin/iptables -w -A nixos-fw \
      -i wg0 -s 10.77.0.2/32 -d 10.77.0.1/32 \
      -p tcp --dport ${toString proxy.port} -j nixos-fw-accept
  '') (lib.attrValues proxies);

  systemd.services = lib.mapAttrs' (
    name: proxy:
    lib.nameValuePair "openbao-demo-${name}" {
      description = "Forward private TCP to the demo ${proxy.description}";
      requires = [ "openbao-demo-${name}.socket" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd ${proxy.target}";
        DynamicUser = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
        ];
      };
    }
  ) proxies;

  systemd.sockets = lib.mapAttrs' (
    name: proxy:
    lib.nameValuePair "openbao-demo-${name}" {
      description = "Private OpenBao demo ${proxy.description} listener";
      wantedBy = [ "sockets.target" ];
      listenStreams = [ "10.77.0.1:${toString proxy.port}" ];
      socketConfig = {
        FreeBind = true;
        NoDelay = true;
      };
    }
  ) proxies;
}
