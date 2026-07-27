{
  config,
  lib,
  ...
}:
let
  user = config.dc-tec.user.name;
  palette = config.home-manager.users.${user}.colorScheme.palette;
  color = name: "#${palette.${name}}";
in
{
  config = lib.mkIf config.dc-tec.isDarwin {
    home-manager.users.${user} = {
      # cmux embeds Ghostty's terminal renderer and reads its XDG config. Keep
      # the renderer configuration declarative without installing Ghostty.app.
      programs.ghostty = {
        enable = true;
        package = null;
        enableZshIntegration = true;
        settings = {
          "font-family" = config.dc-tec.font;
          "font-size" = 11;
          "sidebar-font-size" = 13;
          "surface-tab-bar-font-size" = 11;

          "background-opacity" = 0.95;
          "background-opacity-cells" = true;
          "background-blur" = 60;

          "cursor-style" = "block";
          "cursor-style-blink" = false;
          "scrollback-limit" = 50000000;
          "unfocused-split-opacity" = 0.9;
          "unfocused-split-fill" = color "base01";
          "window-padding-x" = 5;
          "window-padding-y" = 5;
          "window-theme" = "dark";
        };
      };

      xdg.configFile."cmux/cmux.json".text = builtins.toJSON {
        "$schema" = "https://raw.githubusercontent.com/manaflow-ai/cmux/main/web/data/cmux.schema.json";
        schemaVersion = 1;

        activePaneBorderColor = color "base0D";
        paneBorderColor = color "base02";

        app = {
          appearance = "dark";
          appIcon = "dark";
          commandPaletteSearchesAllSurfaces = true;
          confirmQuit = "dirty-only";
          focusPaneOnFirstClick = true;
          newWorkspacePlacement = "afterCurrent";
          openMarkdownInCmuxViewer = true;
          openSupportedFilesInCmux = true;
          preferredEditor = "nvim";
          workspaceInheritWorkingDirectory = true;
        };

        browser = {
          interceptTerminalOpenCommandInCmuxBrowser = true;
          openTerminalLinksInCmuxBrowser = true;
          theme = "dark";
        };

        shortcuts = {
          showModifierHoldHints = true;
          bindings = {
            # Keep Ctrl+h/j/k/l available to NixVim. Cmd+Option crosses the
            # editor boundary and navigates cmux panes with the same geometry.
            focusLeft = "cmd+opt+h";
            focusDown = "cmd+opt+j";
            focusUp = "cmd+opt+k";
            focusRight = "cmd+opt+l";

            newTab = "cmd+n";
            newSurface = "cmd+t";
            closeTab = "cmd+w";
            splitRight = "cmd+d";
            splitDown = "cmd+shift+d";
            toggleSplitZoom = "cmd+shift+enter";
            equalizeSplits = "ctrl+cmd+=";

            nextSidebarTab = "ctrl+cmd+]";
            prevSidebarTab = "ctrl+cmd+[";
            nextSurface = "cmd+shift+]";
            prevSurface = "cmd+shift+[";
            selectWorkspaceByNumber = "cmd+1";
            selectSurfaceByNumber = "ctrl+1";

            # Let embedded browsers and terminal applications own Cmd+[ and
            # Cmd+] instead of using them for cmux focus history.
            focusHistoryBack = null;
            focusHistoryForward = null;
          };
        };

        sidebar = {
          branchLayout = "inline";
          makePullRequestsClickable = true;
          openPortLinksInCmuxBrowser = true;
          openPullRequestLinksInCmuxBrowser = true;
          pathLastSegmentOnly = true;
          showAgentActivity = true;
          showBranchDirectory = true;
          showCustomMetadata = true;
          showNotificationMessage = true;
          showPorts = true;
          showProgress = true;
          showPullRequests = true;
          watchGitStatus = true;
        };

        sidebarAppearance = {
          darkModeTintColor = color "base00";
          matchTerminalBackground = true;
          tintColor = color "base00";
          tintOpacity = 0.12;
        };

        workspaceColors = {
          indicatorStyle = "leftRail";
          notificationBadgeColor = color "base08";
          selectionColor = color "base0D";
          colors = {
            Blue = color "base0D";
            Teal = color "base0C";
            Green = color "base0B";
            Amber = color "base0A";
            Orange = color "base09";
            Red = color "base08";
            Purple = color "base0E";
            Rose = color "base0F";
            Charcoal = color "base03";
          };
        };
      };
    };
  };
}
