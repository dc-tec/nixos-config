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
      "curl"
      "unzip"
      "fontconfig"
      "ical-buddy"
      "sketchybar"
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
