_: {
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
    };

    taps = [
      "homebrew/services"
    ];

    brews = [
      "curl"
      "unzip"
    ];

    casks = [
      "firefox"
      "microsoft-edge"
      "whatsapp"
      "mattermost"
      "obsidian"
      "kitty"
      "visual-studio-code"
      "raycast"
      "font-0xproto"
      "mac-mouse-fix"
    ];
  };
}
