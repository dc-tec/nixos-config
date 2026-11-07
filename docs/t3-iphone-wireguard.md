# T3 access from iPhone

The iPhone reaches T3 on the Mac through the Forge WireGuard hub. T3 listens
on `127.0.0.1:3773`. A separate Caddy instance listens on `10.77.0.2:3773` and
proxies HTTP and WebSocket connections to T3. It accepts requests only from the
iPhone (`10.77.0.4`) and the workstation (`10.77.0.2`).

Forge permits the phone to reach only TCP port 3773 on the workstation. It
blocks access to its own services, Chad, the lab networks, and other forwarding
destinations. The phone has its own WireGuard key pair; its private key stays on
the phone.

The mobile restrictions stay installed while the host firewall stops or
reloads. Reloading replaces the mobile chain rules atomically.

## Configure the iPhone

In the WireGuard app, create a tunnel from scratch and generate a key pair.
Configure these fields:

| Field | Value |
| --- | --- |
| Interface address | `10.77.0.4/32` |
| Peer public key | `bkf+oPNj3mK7i9P5DalNs3f3ez2wFPagned7K+ePYgo=` |
| Peer endpoint | `vpn.decort.tech:51820` |
| Peer allowed IPs | `10.77.0.2/32` |
| Peer persistent keepalive | `25` |
| DNS | Leave empty |

The public key registered for this phone is
`Zwx19YlJukhneJL87HzRauDd1KGkkTiRd6R8fbJBED0=`. If the phone generates a new
key pair, replace the peer public key in `machines/forge/wireguard.nix` and
activate Forge before connecting.

The allowed IP selects the workstation route. The Forge firewall enforces the
port restriction. Other phone traffic uses its normal connection.

## Pair T3

1. Keep the Mac awake with T3 running and its `forge` WireGuard tunnel connected.
2. Activate the iPhone's WireGuard tunnel.
3. Create a fresh pairing link on the Mac with the bundled T3 command:

   ```sh
   ~/.t3/bin/t3 auth pairing create \
     --base-url http://10.77.0.2:3773 \
     --label 'iPhone WireGuard' --ttl 5m
   ```

4. In the iPhone T3 app, add an environment using the complete pairing link, or
   enter `http://10.77.0.2:3773` with the new pairing code.
5. Disable Wi-Fi on the phone and confirm that T3 loads the Mac's projects over
   cellular.

Pairing links contain credentials. Share them only with the intended device.
After pairing, the saved device session replaces the one-time pairing token.

## Proxy lifecycle

`modules/darwin/t3-wireguard-proxy.nix` defines the
`org.nixos.t3-wireguard-proxy` user LaunchAgent. It starts at login and retries
after a failure, including when the VPN address is absent. It runs without root
and does not restart T3 or the existing development Caddy instance.

Inspect the service and listeners:

```sh
launchctl print gui/$(id -u)/org.nixos.t3-wireguard-proxy
lsof -nP -iTCP:3773 -sTCP:LISTEN
```

The expected listeners are T3 on `127.0.0.1:3773` and Caddy on
`10.77.0.2:3773`. The proxy does not listen on the Mac's LAN addresses.

## Transport boundary

HTTPS and public DNS are deferred. WireGuard encrypts each network hop, but
Forge decrypts and re-encrypts traffic between peers. Forge can therefore read
the HTTP traffic, including T3 credentials. This setup trusts the Forge host.

For end-to-end HTTPS, issue a publicly trusted certificate through DNS-01 on the
Mac and terminate TLS at the Mac's VPN-only proxy. For example,
`t3-workstation.decort.tech` can resolve to `10.77.0.2` with a DNS-only record.
Keep the certificate private key on the Mac. Update the Forge port restriction
and the phone's saved T3 route when activating that endpoint.
