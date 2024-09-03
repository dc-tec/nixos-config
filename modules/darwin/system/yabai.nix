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
      window_opacity = "off";

      top_padding = 6;
      bottom_padding = 6;
      left_padding = 6;
      right_padding = 6;
      window_gap = 6;

      extraConfig = ''
        # rules
        yabai -m rule --add app='About This Mac' manage=off
        yabai -m rule --add app='System Information' manage=off
        yabai -m rule --add app='System Preferences' manage=off
        yabai -m rule --add app=kitty border=off

        # Load scripting addition
        yabai -m signal --add event=dock_did_restart \
          action="sudo yabai --load-sa"
        sudo yabai --load-sa
      '';
    };
  };
}
