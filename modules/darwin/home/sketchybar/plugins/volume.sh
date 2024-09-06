#!/usr/bin/env sh

WIDTH=100

volume_change() {
  source "$CONFIG_DIR/icons.sh"
  source "$CONFIG_DIR/colors.sh"

  case $INFO in
    [6-9][0-9]|100) ICON=$VOLUME_100; COLOR=$RED
    ;;
    [3-5][0-9]) ICON=$VOLUME_66; COLOR=$ORANGE
    ;;
    [1-2][0-9]) ICON=$VOLUME_33; COLOR=$YELLOW
    ;;
    [1-9]) ICON=$VOLUME_10; COLOR=$GREEN
    ;;
    0) ICON=$VOLUME_0; COLOR=$WHITE
    ;;
    *) ICON=$VOLUME_100; COLOR=$MAGENTA
  esac

  sketchybar --set volume_icon label=$ICON \
             --set volume_icon label.color=$COLOR \
             --set $NAME slider.percentage=$INFO

  INITIAL_WIDTH="$(sketchybar --query $NAME | jq -r ".slider.width")"
  if [ "$INITIAL_WIDTH" -eq "0" ]; then
    sketchybar --animate tanh 30 --set $NAME slider.width=$WIDTH
  fi

  sleep 2

  # Check wether the volume was changed another time while sleeping
  FINAL_PERCENTAGE="$(sketchybar --query $NAME | jq -r ".slider.percentage")"
  if [ "$FINAL_PERCENTAGE" -eq "$INFO" ]; then
    sketchybar --animate tanh 30 --set $NAME slider.width=0
  fi
}

mouse_clicked() {
  osascript -e "set volume output volume $PERCENTAGE"
}

case "$SENDER" in
  "volume_change") volume_change
  ;;
  "mouse.clicked") mouse_clicked
  ;;
esac
