{
  config,
  lib,
  ...
}: {
  options.dc-tec.core.routing.enable = lib.mkEnableOption "network routing";

  config = lib.mkIf config.dc-tec.core.routing.enable {
    services.frr = {
      bgp = {
        enable = true;
        ## Chad Kubernetes BGP Configuration
        config = ''
          !
          frr defaults traditional
          hostname chad
          log syslog
          no ipv6 forwarding
          service integrated-vtysh-config
          !
          router bgp 69420
           no bgp ebgp-requires-policy
           bgp log-neighbor-changes
           bgp router-id 10.0.1.125
           neighbor 172.50.0.2 remote-as 42069
           neighbor 172.50.0.2 update-source frr0
           neighbor 172.50.0.2 description control_node01

           neighbor 172.50.0.3 remote-as 42069
           neighbor 172.50.0.3 update-source frr0
           neighbor 172.50.0.3 description control_node02

           neighbor 172.50.0.4 remote-as 42069
           neighbor 172.50.0.4 update-source frr0
           neighbor 172.50.0.4 description control_node03

           neighbor 172.50.0.20 remote-as 42069
           neighbor 172.50.0.20 update-source frr0
           neighbor 172.50.0.20 description worker_node01

           neighbor 172.50.0.21 remote-as 42069
           neighbor 172.50.0.21 update-source frr0
           neighbor 172.50.0.21 description worker_node01

           neighbor 172.50.0.22 remote-as 42069
           neighbor 172.50.0.22 update-source frr0
           neighbor 172.50.0.22 description worker_node01

          !
          address-family ipv4 unicast
           network 172.50.0.0/24
           neighbor 172.50.0.2 activate
           neighbor 172.50.0.3 activate
           neighbor 172.50.0.4 activate
           neighbor 172.50.0.20 activate
           neighbor 172.50.0.21 activate
           neighbor 172.50.0.22 activate

           neighbor 172.50.0.2 send-community
           neighbor 172.50.0.3 send-community
           neighbor 172.50.0.4 send-community
           neighbor 172.50.0.20 send-community
           neighbor 172.50.0.21 send-community
           neighbor 172.50.0.22 send-community

           neighbor 172.50.0.2 next-hop-self
           neighbor 172.50.0.3 next-hop-self
           neighbor 172.50.0.4 next-hop-self
           neighbor 172.50.0.20 next-hop-self
           neighbor 172.50.0.21 next-hop-self
           neighbor 172.50.0.22 next-hop-self

           exit-address-family
           !
          !
          route-map ALLOW-ALL permit 100
          !
          line vty
          !
          end
        '';
      };
    };
  };
}
