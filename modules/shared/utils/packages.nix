{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
{
  config = {
    # System Wide Packages
    environment.systemPackages = with pkgs; [
      wget
      curl
      coreutils
      unzip
      openssl
      dnsutils
      nmap
      util-linux
      whois
      moreutils
      git
      age
      sops
      ssh-to-age
      tcpdump
      nvd
      tree
    ];

    # User Packages
    home-manager.users.${config.dc-tec.user.name} = {
      home = {
        packages =
          with pkgs;
          [
            tlrc
            fontconfig
            fd
            jq
            yq
            direnv
            atac
            comma
            autojump
            inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
            gemini-cli
            cloudflared
          ]
          # Keep graphical applications off the deliberately minimal WSL host.
          ++ lib.optionals (config.dc-tec.isDarwin || (config.dc-tec.graphical.enable or false)) [
            bitwarden-desktop
            brave
            ffmpeg
          ]
          # Codex and Claude Code use their faster npm update channel on Darwin.
          # Keep the Nix-managed packages on Linux.
          ++ lib.optionals config.dc-tec.isLinux [
            claude-code
            codex
          ];
      };
    };
  };
}
