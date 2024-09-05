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
      {
        name = "sketchybar";
        start_service = true;
      }
    ];

    casks = [
      "firefox"
      "microsoft-edge"
      "whatsapp"
      "mattermost"
      "obsidian"
      "visual-studio-code"
      "raycast"
      "font-0xproto"
      "mac-mouse-fix"
      "docker"
    ];
  };
}
