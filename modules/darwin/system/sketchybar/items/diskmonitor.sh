#!/bin/bash

diskmonitor=(
  # icon.font="CaskaydiaCove Nerd Font Mono:Regular:24"
  icon.font.size=14
  icon.padding_right=0
  label.drawing=off
  y_offset=1
  update_freq=300
  updates=when_shown
  script="$PLUGIN_DIR/diskmonitor.sh"
)

misc=(
  icon.drawing=off
  width=0
  padding_right=4
  update_freq=300
  updates=when_shown
  label.drawing=off
  #click_script="open -a DaisyDisk.app"
)

diskmonitor_label=(
  "${misc[@]}"
  label.font="$FONT:Semibold:8"
  y_offset=5
)

diskmonitor_value=(
  "${misc[@]}"
  label.font="$FONT:Bold:10"
  y_offset=-3
)

sketchybar                                          \
  --add item diskmonitor.label right                \
  --set diskmonitor.label "${diskmonitor_label[@]}" \
                                                    \
  --add item diskmonitor.value right                \
  --set diskmonitor.value "${diskmonitor_value[@]}" \
                                                    \
  --add item diskmonitor right                      \
  --set diskmonitor "${diskmonitor[@]}"             \
  --subscribe diskmonitor mouse.clicked
