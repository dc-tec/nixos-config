{
  config,
  lib,
  inputs,
  ...
}: {
  config = lib.mkIf config.dc-tec.graphical.hyprland.enable {
    home-manager.users.roelc = {
      imports = [
        inputs.hyprlock.homeManagerModules.hyprlock
      ];

      programs.hyprlock = {
        enable = true;

        general = {
          no_fade_in = false;
          grace = 0;
          disable_loading_bar = true;
        };

        backgrounds = [
          {
            path = "${/. + ../_assets/lockscreen.png}";
            blur_passes = 1;
            contrast = 0.8916;
            brightness = 0.8172;
            vibrancy = 0.1696;
            vibrancy_darkness = 0.0;
          }
        ];

        input-fields = [
          {
            size = {
              width = 250;
              height = 60;
            };
            outline_thickness = 2;
            dots_size = 0.2;
            dots_spacing = 0.2;
            dots_center = true;
            outer_color = "rgba(0, 0, 0, 0)";
            inner_color = "rgba(0, 0, 0, 0.5)";
            font_color = "rgb(200, 200, 200)";
            fade_on_empty = false;
            placeholder_text = "<i>Feed me your secret...</i>";
            hide_input = false;
            position = {
              x = 0;
              y = 120;
            };
            halign = "center";
            valign = "center";
          }
        ];

        labels = [
          # Time
          {
            font_family = "Iosevka Nerd Font";
            text = "cmd[update:1000] /run/current-system/sw/bin/date +'%-I:%M%p')";
            font_size = 120;
            position = {
              x = 0;
              y = -300;
            };
            halign = "center";
            valign = "top";
          }
          # User
          {
            font_family = "Iosevka Nerd Font";
            text = "Yo..., Wassup!";
            font_size = 25;
            position = {
              x = 0;
              y = -40;
            };
            halign = "center";
            valign = "center";
          }
        ];
      };
    };

    security.pam.services.hyprlock = {};
  };
}
