{ config, pkgs, ... }:
let
  home = config.users.users.${config.system.primaryUser}.home;
  caddyfile = pkgs.writeText "t3-wireguard.Caddyfile" ''
    {
      admin off
      auto_https off
      persist_config off
    }

    http://10.77.0.2:3773 {
      bind 10.77.0.2

      @allowed remote_ip 10.77.0.2 10.77.0.4
      handle @allowed {
        reverse_proxy 127.0.0.1:3773
      }
      handle {
        respond "Forbidden" 403
      }
    }
  '';
in
{
  # Homebrew supplies Caddy. Keep this instance separate from localdev-router.
  launchd.user.agents.t3-wireguard-proxy.serviceConfig = {
    ProgramArguments = [
      "/opt/homebrew/bin/caddy"
      "run"
      "--config"
      (toString caddyfile)
      "--adapter"
      "caddyfile"
    ];
    EnvironmentVariables = {
      XDG_DATA_HOME = "${home}/Library/Application Support/t3-wireguard";
      XDG_CONFIG_HOME = "${home}/Library/Application Support/t3-wireguard";
    };
    RunAtLoad = true;
    KeepAlive = true;
    ThrottleInterval = 30;
    StandardOutPath = "${home}/Library/Logs/t3-wireguard-proxy.log";
    StandardErrorPath = "${home}/Library/Logs/t3-wireguard-proxy.log";
  };
}
