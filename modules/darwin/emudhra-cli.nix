{ lib, pkgs, ... }:
let
  tools = pkgs.callPackage ../../pkgs/ca-tools { };
  policy = pkgs.writeText "emudhra-excluded-roots.json" (
    builtins.toJSON (import ../../lib/emudhra-distrust.nix)
  );
  arguments = map toString [
    (lib.getExe tools.filterBundle)
    policy
    "/etc/ssl/cert.pem"
    "--backup"
    "/var/lib/nixos-trust-backups/apple-cert.pem.before-emudhra"
  ];
  pipConfig = pkgs.writeText "emudhra-pip.conf" ''
    [global]
    cert = /etc/ssl/cert.pem
  '';
in
{
  # Apple CLI tools read a separate bundle that macOS updates can replace.
  # Preserve unrelated roots and retain the original file for rollback.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    ${lib.escapeShellArgs arguments}

    # Nix OpenSSL/Python builds can reference the installer's default profile.
    # Update its CA package while retaining the other installed packages.
    default_ca=/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt
    if [[ -f "$default_ca" && "$(readlink -f "$default_ca")" != ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt ]]; then
      ${pkgs.nix}/bin/nix-env --profile /nix/var/nix/profiles/default --install ${pkgs.cacert}
    fi

    # Apple's Python 3.9 pip vendors an independent CA bundle. Global pip
    # configuration also reaches existing virtual environments and root's pip.
    pip_config='/Library/Application Support/pip/pip.conf'
    if [[ ! -e "$pip_config" || "$(readlink "$pip_config" || true)" == /nix/store/*-emudhra-pip.conf ]]; then
      mkdir -p '/Library/Application Support/pip'
      ln -sfn ${pipConfig} "$pip_config"
    elif ! cmp -s ${pipConfig} "$pip_config"; then
      echo "Refusing to replace an unmanaged global pip configuration: $pip_config" >&2
      exit 1
    fi
  '';

  launchd.daemons.emudhra-ca-filter.serviceConfig = {
    ProgramArguments = arguments;
    RunAtLoad = true;
    WatchPaths = [ "/etc/ssl/cert.pem" ];
    ThrottleInterval = 30;
    StandardOutPath = "/var/log/emudhra-ca-filter.log";
    StandardErrorPath = "/var/log/emudhra-ca-filter.log";
  };
}
