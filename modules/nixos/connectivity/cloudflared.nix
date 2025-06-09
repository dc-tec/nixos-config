{
  config,
  lib,
  ...
}:
{
  options.dc-tec.core.cloudflared.enable = lib.mkEnableOption "cloudflared";

  config = lib.mkIf config.dc-tec.core.cloudflared.enable {
    systemd.services."enable-cloudflare" = {
      description = "Enable Cloudflared Tunnel";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "/etc/profiles/per-user/roelc/bin/cloudflared tunnel --config /home/roelc/.cloudflared/config.yml run";
        Type = "simple";
      };
    };
  };
}
