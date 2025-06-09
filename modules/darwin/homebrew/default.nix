_: {
  homebrew = {
    enable = true;

    onActivation = {
      upgrade = true;
      autoUpdate = true;
      cleanup = "zap";
    };

    global = {
      autoUpdate = true;
      brewfile = true;
      lockfiles = true;
    };

    taps = [
      "homebrew/services"
      "FelixKratz/formulae"
      "hashicorp/tap"
      "jeffreywildman/homebrew-virt-manager"
    ];

    brews = [
      "curl"
      "unzip"
      "fontconfig"
      "ical-buddy"
      {
        name = "sketchybar";
        start_service = true;
      }
      {
        name = "borders";
        start_service = true;
      }
      "ifstat"
      "jq"
      "yq"
      "hashicorp/tap/vault"
      "hashicorp/tap/boundary"
      "hashicorp/tap/consul"
      "hashicorp/tap/nomad"
      "hashicorp/tap/packer"
      "cloudflared"
      "gpg"
      "pinentry-mac"
      "pre-commit"
      "just"
      "netcat"
      "gh"
      "tflint"
      "terraform-ls"
      "container-structure-test"
      "virt-manager"
      "virt-viewer"
      "azure-cli"
      "opentofu"
      "openbao"
      "k3d"
      "hcloud"
      "coreutils"
      "kwctl"
      "kind"
      "goreleaser"
      "gosec"
      "httpie"
      "npm"
      "ollama"
    ];

    casks = [
      "firefox"
      "arc"
      "thunderbird"
      "microsoft-edge"
      "whatsapp"
      "mattermost"
      "obsidian"
      "chatgpt"
      "visual-studio-code"
      "raycast"
      "font-0xproto"
      "font-0xproto-nerd-font"
      "mac-mouse-fix"
      "docker"
      "font-sf-mono"
      "sf-symbols"
      "font-material-symbols"
      "font-material-icons"
      "betterdisplay"
      "spotify"
      "cursor"
      "notion"
      "shottr"
      "powershell"
      "slack"
      "citrix-workspace"
      "openvpn-connect"
      "zoom"
      "lm-studio"
    ];
  };
}
