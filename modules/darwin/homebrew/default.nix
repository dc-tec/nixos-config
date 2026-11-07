_: {
  homebrew = {
    enable = true;

    onActivation = {
      upgrade = true;
      autoUpdate = true;
      cleanup = "check";
    };

    global = {
      autoUpdate = true;
      brewfile = true;
    };

    taps = [
      "anomalyco/tap"
      "FelixKratz/formulae"
      "manaflow-ai/cmux"
    ];

    brews = [
      "ical-buddy"
      {
        name = "sketchybar";
        start_service = true;
      }
      {
        name = "borders";
        start_service = true;
      }
      "actionlint"
      "aws-vault"
      "checkov"
      "glab"
      "gnupg"
      "pinentry-mac"
      "container-structure-test"
      # Node owns the mutable npm-global AI CLI installations on Darwin.
      "node"
      "opam"
      "bitwarden-cli"
      "caddy"
      "cloc"
      "pnpm"
      "semgrep"
      "anomalyco/tap/opencode"
      "swtpm"
      "trivy"
      "unbound"
      "qemu"
      "git-lfs"
      "poppler"
      "saml2aws"
      # Retain installed libraries during Homebrew cleanup checks.
      "libnghttp3"
      "libngtcp2"
      "openssl@3"
      "python@3.14"
    ];

    casks = [
      "brave-browser"
      "thunderbird"
      "whatsapp"
      "mattermost"
      "obsidian"
      "obs"
      "chatgpt"
      "visual-studio-code"
      "raycast"
      "font-0xproto"
      "font-0xproto-nerd-font"
      "mac-mouse-fix"
      "font-sf-mono"
      "sf-symbols"
      "font-material-symbols"
      "font-material-icons"
      "betterdisplay"
      "spotify"
      "cmux"
      "notion"
      "shottr"
      "powershell"
      "slack"
      "citrix-workspace"
      "openvpn-connect"
      "zoom"
      "orbstack"
      "session-manager-plugin"
    ];
  };
}
