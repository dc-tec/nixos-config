#!/bin/bash

volume_slider=(
  script="$PLUGIN_DIR/volume.sh"
  updates=on
  label.drawing=off
  icon.drawing=off
  slider.highlight_color=$HIGHLIGHT
  slider.background.height=8
  slider.background.corner_radius=12
  slider.background.color=$BASE
  padding_left=0
  padding_right=0
)

volume_icon=(
  click_script="$PLUGIN_DIR/volume_click.sh"
  icon=$VOLUME_100
  label.drawing=off
)

sketchybar --add slider volume right              \
           --set volume "${volume_slider[@]}"     \
           --subscribe volume volume_change       \
                              mouse.clicked       \
                              mouse.entered       \
                              mouse.exited        \
                              mouse.exited.global \
                                                  \
           --add item volume_icon right           \
           --set volume_icon "${volume_icon[@]}"
