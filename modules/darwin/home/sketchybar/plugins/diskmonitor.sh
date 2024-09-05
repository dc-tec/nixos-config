#!/bin/bash

# Load global styles, colors and icons
source "$CONFIG_DIR/defaults.sh"

update() {

  VOLUMEDATA=$(df -H /System/Volumes/Data)
  USEDSPACEPERCENT=$(echo "$VOLUMEDATA" | awk 'END {print $5}' | sed 's/%//')
  FREESPACE=$(echo "$VOLUMEDATA" | awk 'END {print $4}' | sed 's/G//')
  FREESPACEPERCENT=$(echo "100 - $USEDSPACEPERCENT" | bc)
  PERCENTAGE=$FREESPACEPERCENT
  COLOR=$ICON_COLOR

  case ${PERCENTAGE} in
  9[8-9] | 100)
    ICON="󰪥"
    COLOR=$GREEN
    ;;
  8[8-9] | 9[0-7])
    ICON="󰪤"
    ;;
  7[6-9] | 8[0-7])
    ICON="󰪣"
    ;;
  6[4-9] | 7[0-5])
    ICON="󰪢"
    ;;
  5[2-9] | 6[0-3])
    ICON="󰪡"
    ;;
  4[0-9] | 5[0-1])
    ICON="󰪠"
    ;;
  2[8-9] | 3[0-9])
    ICON="󰪟"
    ;;
  [6-9] | 1[0-9] | 2[0-7])
    ICON="󰪞"
    ;;
  [0-5])
    ICON="󰝦"
    COLOR=$ORANGE
    ;;
  *)
    # Handle other cases if needed
    ICON="󰅚"
    COLOR=$HIGHLIGHT
    ;;
  esac

  sketchybar --set $NAME icon=$ICON icon.color=$COLOR
  sketchybar --set $NAME.value label="$PERCENTAGE%"
}

label_toggle() {
  update

  DRAWING_STATE=$(sketchybar --query $NAME.value | jq -r '.label.drawing')

  if [[ $DRAWING_STATE == "on" ]]; then
    DRAWING="off"
    PADDING="0"
  else
    DRAWING="on"
    PADDING="30"
  fi

  sketchybar --set $NAME.value label.drawing=$DRAWING \
    --set $NAME.label label=$FREESPACE'GB' label.drawing=$DRAWING \
    --set $NAME icon.padding_right=$PADDING

}

case "$SENDER" in
"routine" | "forced")
  update
  ;;
"mouse.clicked")
  label_toggle
  ;;
esac
