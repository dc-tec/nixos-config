#!/bin/bash

# Load global styles, colors and icons
source "$CONFIG_DIR/defaults.sh"

check_state() {
   #DND_ENABLED=$(cat ~/Library/DoNotDisturb/DB/Assertions.json | jq .data[0].storeAssertionRecords)

  # Alternate SLOW method:
  DND_ENABLED=$(defaults read com.apple.controlcenter "NSStatusItem Visible FocusModes")

  if [ "$DND_ENABLED" -eq 0 ]; then
    COLOR=$SKY
  else
    COLOR=$TEAL
  fi

  sketchybar --set $NAME icon.color=$COLOR
}

update_icon() {
  if [ "$SENDER" == "focus_off" ]; then
    COLOR=$SKY
  else
    COLOR=$TEAL
  fi

  sketchybar --set $NAME icon.color=$COLOR
}

toggle_dnd() {
  osascript -e 'tell application "System Events" to keystroke "\\" using {control down, shift down, command down, option down}'
}

case "$SENDER" in
"routine" | "forced")
  check_state
  ;;
"focus_on" | "focus_off")
  update_icon
  ;;
"mouse.clicked")
  toggle_dnd
  ;;
esac
