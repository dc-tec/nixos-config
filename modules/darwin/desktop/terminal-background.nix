{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = config.dc-tec.user.name;
  homeDirectory = config.dc-tec.user.homeDirectory;
  stateDirectory = "${homeDirectory}/.local/state/terminal-background";
  dataDirectory = "${homeDirectory}/.local/share/terminal-background";
  ghosttyStateFile = "${stateDirectory}/ghostty.conf";
  kittyStateFile = "${stateDirectory}/kitty.conf";
  logoPath = "${dataDirectory}/adfinis-logo.png";

  adfinisLogo =
    pkgs.runCommand "adfinis-terminal-background.png"
      {
        nativeBuildInputs = [ pkgs.imagemagick ];
      }
      ''
        magick \
          -background none \
          -fill white \
          -font ${./files/adfinis_logo.ttf} \
          -pointsize 512 \
          'label:' \
          -trim +repage \
          -resize '320x320>' \
          -gravity center \
          -extent 1024x640 \
          PNG32:"$out"
      '';

  kittyBackgroundConfig = pkgs.writeShellScript "kitty-terminal-background-config" ''
    if [[ -s ${lib.escapeShellArg kittyStateFile} ]]; then
      ${pkgs.coreutils}/bin/cat ${lib.escapeShellArg kittyStateFile}
    fi
  '';

  toggleTerminalBackground = pkgs.writeShellApplication {
    name = "toggle-terminal-background";
    text = ''
      state_directory=${lib.escapeShellArg stateDirectory}
      ghostty_state_file=${lib.escapeShellArg ghosttyStateFile}
      kitty_state_file=${lib.escapeShellArg kittyStateFile}
      logo_path=${lib.escapeShellArg logoPath}

      requested_state="''${1:-toggle}"
      case "$requested_state" in
        toggle)
          if [[ -s "$ghostty_state_file" ]]; then
            requested_state=off
          else
            requested_state=on
          fi
          ;;
        on|off)
          ;;
        status)
          if [[ -s "$ghostty_state_file" ]]; then
            echo "Adfinis terminal background: on"
          else
            echo "Adfinis terminal background: off"
          fi
          exit 0
          ;;
        *)
          echo "Usage: toggle-terminal-background [toggle|on|off|status]" >&2
          exit 2
          ;;
      esac

      mkdir -p "$state_directory"

      if [[ "$requested_state" == on ]]; then
        ghostty_temporary_file="$(mktemp "$state_directory/.ghostty.conf.XXXXXX")"
        kitty_temporary_file="$(mktemp "$state_directory/.kitty.conf.XXXXXX")"
        trap 'rm -f "$ghostty_temporary_file" "$kitty_temporary_file"' EXIT

        printf '%s\n' \
          "background-image = $logo_path" \
          'background-image-opacity = 0.08' \
          'background-image-position = center' \
          'background-image-fit = contain' \
          'background-image-repeat = false' \
          >"$ghostty_temporary_file"

        printf '%s\n' \
          "background_image $logo_path" \
          >"$kitty_temporary_file"

        mv "$ghostty_temporary_file" "$ghostty_state_file"
        mv "$kitty_temporary_file" "$kitty_state_file"
        trap - EXIT
      else
        rm -f "$ghostty_state_file" "$kitty_state_file"
      fi

      if /usr/bin/pgrep -qx cmux; then
        /usr/bin/osascript >/dev/null <<'APPLESCRIPT'
      tell application "cmux"
        if (count of windows) > 0 and (count of terminals of front window) > 0 then
          set targetTerminal to focused terminal of selected tab of front window
          if targetTerminal is missing value then
            set targetTerminal to first terminal of front window
          end if
          perform action "reload_config" on targetTerminal
        end if
      end tell
      APPLESCRIPT
      fi

      shopt -s nullglob
      for kitty_socket in /tmp/kitty-${user}-*.sock; do
        [[ -S "$kitty_socket" ]] || continue
        if [[ "$requested_state" == on ]]; then
          if ! ${pkgs.kitty}/bin/kitten @ \
            --to "unix:$kitty_socket" \
            set-background-image \
            --all \
            --configured \
            --layout cscaled \
            "$logo_path" \
            >/dev/null; then
            echo "Cannot update kitty through $kitty_socket" >&2
          fi
        else
          if ! ${pkgs.kitty}/bin/kitten @ \
            --to "unix:$kitty_socket" \
            set-background-image \
            --all \
            --configured \
            none \
            >/dev/null; then
            echo "Cannot update kitty through $kitty_socket" >&2
          fi
        fi
      done

      echo "Adfinis terminal background: $requested_state"
    '';
  };
in
{
  home-manager.users.${user} = {
    home.packages = [ toggleTerminalBackground ];

    xdg.dataFile."terminal-background/adfinis-logo.png".source = adfinisLogo;

    # Both terminal renderers load a mutable file so the generated Home
    # Manager configuration can remain read-only. A missing file means off.
    programs.ghostty.settings."config-file" = "?${ghosttyStateFile}";
    programs.kitty = {
      extraConfig = lib.mkAfter ''
        geninclude ${kittyBackgroundConfig}
      '';
      settings = {
        # Permit only the image command. Other remote-control commands remain
        # unavailable through the local socket.
        allow_remote_control = "password";
        background_image_layout = "cscaled";
        background_image_linear = true;
        background_tint = "0.92";
        listen_on = "unix:/tmp/kitty-${user}-{kitty_pid}.sock";
        remote_control_password = ''"" set-background-image'';
      };
    };
  };

  services.skhd.skhdConfig = lib.mkAfter ''

    # Toggle the faint Adfinis background only when cmux or kitty has focus.
    cmd + shift - b [
      "cmux"  : ${toggleTerminalBackground}/bin/toggle-terminal-background
      "kitty" : ${toggleTerminalBackground}/bin/toggle-terminal-background
      *         ~
    ]
  '';
}
