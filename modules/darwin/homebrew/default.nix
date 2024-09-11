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
    ];

    casks = [
      "firefox"
      "microsoft-edge"
      "whatsapp"
      "mattermost"
      "obsidian"
      "chatgpt"
      "visual-studio-code"
      "raycast"
      "font-0xproto"
      "mac-mouse-fix"
      "docker"
      "font-sf-mono"
      "sf-symbols"
      "font-material-symbols"
      "font-material-icons"
    ];
  };
}
