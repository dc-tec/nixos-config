{pkgs, ...}: {
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;

    config = {
      layout = "bsp";
      window_placement = "second_child";
      window_shadow = "off";
      mouse_follows_focus = "on";
      focus_follows_mouse = "autoraise";
      window_opacity = "true";

      top_padding = 6;
      bottom_padding = 6;
      left_padding = 6;
      right_padding = 6;
      window_gap = 6;

      extraConfig = ''
        # external bar
        yabai -m config external_bar all:32:0

        # spaces
        yabai -m space 2 --label work
        yabai -m space 3 --label chat
        yabai -m space 4 --label notes

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
