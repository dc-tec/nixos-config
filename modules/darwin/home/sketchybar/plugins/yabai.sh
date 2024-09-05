#!/bin/bash
source "$CONFIG_DIR/defaults.sh"
source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

set_icon() {
  CURRENT_SID=$(/run/current-system/sw/bin/yabai -m query --spaces index --space | /etc/profiles/per-user/roelc/bin/jq -r '.index')
  FRONT_APP_LABEL_COLOR="$(sketchybar --query space.$CURRENT_SID | /etc/profiles/per-user/roelc/bin/jq -r ".label.highlight_color")"
  COLOR=$LABEL_COLOR
  WIDTH=28

  WINDOW=$(/run/current-system/sw/bin/yabai -m query --windows is-floating,split-type,has-fullscreen-zoom,is-sticky,stack-index --window)
  read -r FLOATING SPLIT FULLSCREEN STICKY STACK_INDEX <<<$(echo "$WINDOW" | /etc/profiles/per-user/roelc/bin/jq -rc '.["is-floating", "split-type", "has-fullscreen-zoom", "is-sticky", "stack-index"]')

  if [[ $STACK_INDEX -gt 0 ]]; then
    LAST_STACK_INDEX=$(/run/current-system/sw/bin/yabai -m query --windows stack-index --window stack.last | /etc/profiles/per-user/roelc/bin/jq '.["stack-index"]')
    ICON=
    LABEL="$(printf "%s/%s" "$STACK_INDEX" "$LAST_STACK_INDEX")"
    COLOR=$FRONT_APP_LABEL_COLOR
    WIDTH="dynamic"
  elif [[ $FLOATING == "true" ]]; then
    ICON=󰉧
  elif [[ $FULLSCREEN == "true" ]]; then
    ICON=
  elif [[ $SPLIT == "vertical" ]]; then
    ICON=
  elif [[ $SPLIT == "horizontal" ]]; then
    ICON=
  else
    ICON=󰋁

  fi

  args=(--bar border_color=$COLOR --animate tanh 10 --set $NAME icon=$ICON icon.color=$COLOR width=$WIDTH)

  [ -z "$LABEL" ] && args+=(label.drawing=off) ||
    args+=(label.drawing=on label="$LABEL" label.color=$COLOR)

  [ -z "$ICON" ] && args+=(icon.width=0) ||
    args+=(icon="$ICON")

  sketchybar -m "${args[@]}"
}

mouse_clicked() {
  /run/current-system/sw/bin/yabai -m space --layout $(/run/current-system/sw/bin/yabai -m query --spaces --space | /etc/profiles/per-user/roelc/bin/jq -r 'if .type == "bsp" then "stack" else "bsp" end')
  set_icon
}

case "$SENDER" in
  "mouse.clicked" | "alfred_trigger")
    mouse_clicked
    ;;
  "window_focus" | "front_app_switched" | "update_yabai_icon" | "space_windows_change")
    set_icon
    ;;
esac
