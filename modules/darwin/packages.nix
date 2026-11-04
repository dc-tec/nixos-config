{
  config,
  inputs,
  outputs,
  pkgs,
  ...
}:
{
  # Unstable Azure CLI currently depends on Fabric with unsupported Invoke 3.
  # Reuse the stable package and select the filtered CA bundle at runtime.
  nixpkgs.overlays = [
    (
      final: _:
      let
        stable = import inputs.nixpkgs-stable {
          inherit (final.stdenv.hostPlatform) system;
        };
      in
      {
        azure-cli = final.symlinkJoin {
          name = "azure-cli-${stable.azure-cli.version}";
          inherit (stable.azure-cli) version meta;
          paths = [ stable.azure-cli ];
          nativeBuildInputs = [ final.makeWrapper ];
          postBuild = ''
            wrapProgram "$out/bin/az" \
              --set-default REQUESTS_CA_BUNDLE "${final.cacert}/etc/ssl/certs/ca-bundle.crt" \
              --set-default SSL_CERT_FILE "${final.cacert}/etc/ssl/certs/ca-bundle.crt"
          '';
        };
      }
    )
  ];

  programs.mas = {
    enable = true;
    packages.WireGuard = 1451685025;
  };

  home-manager.users.${config.dc-tec.user.name}.home.packages = [
    outputs.packages.${pkgs.stdenv.hostPlatform.system}.forge-tools
  ];
}
