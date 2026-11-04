{ pkgs, ... }:
{
  imports = [
    ./alerting.nix
    ./backup.nix
    ./cache.nix
    ./development-vm.nix
    ./monitoring.nix
  ];

  system.activationScripts.retireGitServiceMetrics.text = ''
    ${pkgs.coreutils}/bin/rm -f -- \
      /var/lib/prometheus-node-exporter-text-files/forge_radicle.prom \
      /var/lib/prometheus-node-exporter-text-files/forge_tangled_knot.prom
  '';
}
