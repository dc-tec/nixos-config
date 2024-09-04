#!/bin/bash

WIDTH=100

detail_on() {
  sketchybar --animate tanh 30 --set volume slider.width=$WIDTH
}

detail_off() {
  sketchybar --animate tanh 30 --set volume slider.width=0
}

toggle_detail() {
  INITIAL_WIDTH=$(sketchybar --query volume | jq -r ".slider.width")
  if [ "$INITIAL_WIDTH" -eq "0" ]; then
    detail_on
  else
    detail_off
  fi
}

toggle_devices() {
  which SwitchAudioSource >/dev/null || exit 0
  source "$CONFIG_DIR/defaults.sh"

  args=(--remove '/volume.device\..*/' --set $NAME popup.drawing=toggle "${menu_defaults[@]}")

  COUNTER=0
  CURRENT="$(SwitchAudioSource -t output -c)"

  while IFS= read -r device; do
    COLOR=$WHITE
    ICON=$ICON_AUDIO_SOURCE
    ICON_COLOR=$TRANSPARENT

    if [ "${device}" == "$CURRENT" ]; then
      COLOR=$HIGHLIGHT
      ICON_COLOR=$HIGHLIGHT
    fi

    args+=(--add item volume.device.$COUNTER popup.$NAME           \
           --set volume.device.$COUNTER label="${device}"          \
                                        "${menu_item_defaults[@]}" \
                                        label.color="$COLOR"       \
                                        icon=$ICON                 \
                                        icon.color=$ICON_COLOR     \
    click_script="SwitchAudioSource -s \"${device}\" && sketchybar --set /volume.device\..*/ label.color=$COLOR --set \$NAME label.color=$COLOR --set $NAME popup.drawing=off")

    COUNTER=$((COUNTER+1))
  done <<< "$(SwitchAudioSource -a -t output)"

  sketchybar -m "${args[@]}" > /dev/null
}

if [ "$BUTTON" = "left" ] || [ "$MODIFIER" = "shift" ]; then
  toggle_devices
else
  toggle_detail
fi
