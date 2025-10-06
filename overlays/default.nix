{ inputs, ... }:
{
  additions = final: prev: import ../pkgs { pkgs = final; };
  stable-packages = final: prev: {
    stable = import inputs.nixpkgs-stable { system = final.system; };
  };

  force-latest =
    final: prev:
    let
      master = import inputs.nixpkgs-master {
        system = final.system;
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
      src = inputs.llama-cpp-src;
    in
    {
      llama-cpp = prev.llama-cpp.overrideAttrs (old: {
        pname = "llama-cpp";
        # Avoid using a hyphenated value in generated build-info, which breaks C++ compile
        version = "0";
        src = src;
        # ensure a clean build when upstream changes build flags
        passthru = (old.passthru or { }) // {
          upstream = src;
        };
      });
    };
}
