#https://github.com/ryan4yin/nix-darwin-kickstarter/blob/main/rich-demo/modules/system.nix
{ pkgs, ... }:
{
  imports = [
    ./yabai.nix
    ./skhd.nix
  ];

  users.users.roelc = {
    home = "/Users/roelc";
  };

  programs.zsh.enable = true;
  environment.shells = [
    pkgs.zsh
  ];
  environment.variables.EDITOR = "nvim";

  security.pam.services.sudo_local.touchIdAuth = true;

  ids.gids.nixbld = 30000;

  time.timeZone = "Europe/Amsterdam";

  fonts = {
    packages = with pkgs; [
      material-design-icons
      font-awesome
      nerd-fonts.symbols-only
      nerd-fonts._0xproto
    ];
  };

  system = {
    stateVersion = 6;
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/\
      Resources/activatesettings -u
    '';

    defaults = {
      dock = {
        autohide = true;
        show-recents = false;
        orientation = "left";
      };

      finder = {
        _FXShowPosixPathInTitle = true;
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        AppleShowAllFiles = true;
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = false;
      };

      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = false;
        "com.apple.sound.beep.feedback" = 0;
        AppleInterfaceStyle = "Dark";
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = true;

        InitialKeyRepeat = 15;
        KeyRepeat = 3;

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        _HIHideMenuBar = true;
      };

      screencapture.location = "~/Pictures/Screenshots";
    };
  };
}
