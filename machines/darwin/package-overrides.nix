{
  # Reuse audited, pinned packages with certificate-free runtime closures.
  # Applications select the filtered CA bundle through their wrappers.
  nixpkgs.overlays = [
    (
      final: previous:
      let
        basePackages = import previous.path {
          system = previous.stdenv.buildPlatform.system;
          config = { };
          overlays = [ ];
        };
        policy = import ../../lib/emudhra-policy.nix { inherit (previous) lib; };
        cachedApplication =
          command: package:
          final.symlinkJoin {
            inherit (package) name version meta;
            paths = [ package ];
            nativeBuildInputs = [ final.makeWrapper ];
            postBuild = ''
              wrapProgram "$out/bin/${command}" \
                --set-default SSL_CERT_FILE "${final.cacert}/etc/ssl/certs/ca-bundle.crt" \
              --set-default REQUESTS_CA_BUNDLE "${final.cacert}/etc/ssl/certs/ca-bundle.crt"
            ''
            + previous.lib.optionalString (command == "devenv") ''
              # The standalone hardened package provides this command.
              rm "$out/bin/secretspec"
            '';
            passthru = {
              emudhraCachedPackage = package;
            }
            // previous.lib.genAttrs (previous.lib.filter (output: output != "out") package.outputs) (
              output: package.${output}
            );
          };
      in
      {
        inherit (basePackages) clippy rustfmt;
        # Reuse matching manual pages without changing the hardened binaries.
        ffmpeg = previous.ffmpeg // {
          man =
            assert previous.ffmpeg.version == basePackages.ffmpeg.version;
            basePackages.ffmpeg.man;
        };
        kubescape =
          let
            package = basePackages.kubescape;
            goVersion = package.go.version or "0";

          in
          if package.version == "4.0.17" && policy.isFixedGo goVersion then
            cachedApplication "kubescape" package
          else
            previous.kubescape;
        jujutsu =
          if basePackages.jujutsu.version == "0.46.0" then
            cachedApplication "jj" basePackages.jujutsu
          else
            previous.jujutsu;
        just =
          if basePackages.just.version == "1.58.0" then
            cachedApplication "just" basePackages.just
          else
            previous.just;
        devenv =
          if basePackages.devenv.version == "2.4.0" then
            cachedApplication "devenv" basePackages.devenv
          else
            previous.devenv;
        pre-commit =
          if basePackages.pre-commit.version == "4.7.0" then
            cachedApplication "pre-commit" basePackages.pre-commit
          else
            previous.pre-commit;
        pythonPackagesExtensions = previous.pythonPackagesExtensions ++ [
          (_pythonFinal: pythonPrevious: {
            black = pythonPrevious.black.overridePythonAttrs (old: {
              # Black also redirects pytest to the shared /tmp directory.
              preCheck =
                (old.preCheck or "")
                + previous.lib.optionalString (old.version == "26.5.1") ''
                  black_test_tmp="$(mktemp -d /tmp/black.XXXXXX)"
                  pytestFlagsArray+=("--basetemp=$black_test_tmp")
                '';
              postCheck =
                (old.postCheck or "")
                + previous.lib.optionalString (old.version == "26.5.1") ''
                  rm -rf -- "$black_test_tmp"
                '';
            });
            aiohttp = pythonPrevious.aiohttp.overridePythonAttrs (old: {
              # The loopback-HTTPS test leaks sockets when port 443 is in use.
              # Close sockets in its mocked transport failure, as asyncio does.
              patches =
                (old.patches or [ ])
                ++ previous.lib.optional (old.version == "3.14.3") ./patches/aiohttp-test-socket-cleanup.patch;
              # Isolate pytest cleanup and keep Unix socket paths short.
              preCheck =
                (old.preCheck or "")
                + previous.lib.optionalString (old.version == "3.14.3") ''
                  aiohttp_test_tmp="$(mktemp -d /tmp/aiohttp.XXXXXX)"
                  pytestFlagsArray+=("--basetemp=$aiohttp_test_tmp")
                '';
              postCheck =
                (old.postCheck or "")
                + previous.lib.optionalString (old.version == "3.14.3") ''
                  rm -rf -- "$aiohttp_test_tmp"
                '';
            });
            # DeepDiff has no runtime CA bundle. Reuse its pinned build
            # instead of rebuilding Polars only for its test dependencies.
            deepdiff =
              if
                pythonPrevious.python.outPath == basePackages.python3.outPath
                && basePackages.python3Packages.deepdiff.version == "8.6.2"
              then
                basePackages.python3Packages.deepdiff
              else
                pythonPrevious.deepdiff;
          })
        ];
        haskell = previous.haskell // {
          compiler = previous.haskell.compiler // {
            ghc9103 = basePackages.haskell.compiler.ghc9103;
          };
        };
      }
    )
  ];
}
