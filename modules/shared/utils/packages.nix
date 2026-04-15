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
        packages = with pkgs; [
          tlrc
          fontconfig
          fd
          jq
          yq
          direnv
          atac
          comma
          autojump
          llama-cpp
          inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
          claude-code
          gemini-cli
          codex
          bitwarden-desktop
          brave
          cloudflared
          ffmpeg
        ];
      };
    };
  };
}
