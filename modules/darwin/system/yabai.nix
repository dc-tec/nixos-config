{...}: {
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;

    config = {
      layout = "bsp";
      window_placement = "second_child";
      window_shadow = "off";
      mouse_follows_focus = "on";
      focus_follows_mouse = "autofocus";
      window_opacity = "off";

      top_padding = 7;
      bottom_padding = 7;
      left_padding = 7;
      right_padding = 7;
      window_gap = 7;

      extraConfig = ''
        # external bar
        yabai -m config external_bar all:36:0

        # spaces
        yabai -m space 1
        yabai -m space 2 --label work
        yabai -m space 3 --label chat
        yabai -m space 4 --label notes
        yabai -m space 5
        yabai -m space 6
        yabai -m space 7
        yabai -m space 8
        yabai -m space 9
        yabai -m space 10

        # rules
        yabai -m rule --add app='About This Mac' manage=off
        yabai -m rule --add app='System Information' manage=off
        yabai -m rule --add app='System Preferences' manage=off
        yabai -m rule --add app="^kitty$" border=off
        yabai -m rule --add app="^Mail$" space=work
        yabai -m rule --add app="^Calendar$" space=work
        yabai -m rule --add app="^Mattermost" space=chat
        yabai -m rule --add app="^WhatsApp$" space=chat
        yabai -m rule --add app="^Notes$" space=notes
        yabai -m rule --add app="^Obsidian$" space=notes

        # Load scripting addition
        yabai -m signal --add event=dock_did_restart \
          action="sudo yabai --load-sa"
        sudo yabai --load-sa
      '';
    };
  };
}
