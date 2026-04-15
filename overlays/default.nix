{ inputs, ... }:
{
  additions =
    final: prev:
    import ../pkgs {
      pkgs = final;
      inherit inputs;
    };
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable { system = final.stdenv.hostPlatform.system; };
  };

  force-latest =
    final: prev:
    let
      master = import inputs.nixpkgs-master {
        system = final.stdenv.hostPlatform.system;
        overlays = [ ];
      };
    in
    {
      nix-init = master.nix-init;
      nurl = master.nurl;
      nix = master.nix;
    };

  llama-cpp-latest =
    final: prev:
    let
      upstream = inputs.llama-cpp-src;
      src = final.runCommand "llama-cpp-source" { } ''
        cp -R ${upstream} "$out"
        chmod -R u+w "$out"
        printf '%s\n' '${builtins.substring 0 7 inputs.llama-cpp-src.rev}' > "$out/COMMIT"
      '';
    in
    {
      llama-cpp = prev.llama-cpp.overrideAttrs (old: {
        pname = "llama-cpp";
        # Avoid using a hyphenated value in generated build-info, which breaks C++ compile
        version = "0";
        src = src;
        npmDepsHash = "sha256-RAFtsbBGBjteCt5yXhrmHL39rIDJMCFBETgzId2eRRk=";
        # ensure a clean build when upstream changes build flags
        passthru = (old.passthru or { }) // {
          upstream = upstream;
        };
      });
    };
}
