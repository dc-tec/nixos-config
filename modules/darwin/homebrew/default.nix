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
      "gpg"
      "pinentry-mac"
      "container-structure-test"
      "npm"
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
      "orbstack"
    ];
  };
}
