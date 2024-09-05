#!/bin/bash

yabai=(
  icon=$YABAI_GRID
  label.drawing=off
  width=28
  script="$PLUGIN_DIR/yabai.sh"
  icon.font="$FONT:Regular:12.0"
  label.padding_right=$PADDINGS
)

# Allows my shortcut / workflow in Alfred to trigger things in Sketchybar
sketchybar --add event alfred_trigger
sketchybar --add event update_yabai_icon

sketchybar --add item yabai left                   \
           --set yabai "${yabai[@]}"               \
           --subscribe yabai space_change          \
                             mouse.scrolled.global \
                             mouse.clicked         \
                             front_app_switched    \
                             space_windows_change  \
                             alfred_trigger        \
                             update_yabai_icon
