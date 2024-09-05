#!/bin/sh

source "$CONFIG_DIR/defaults.sh"

front_app=(
            script="$PLUGIN_DIR/front_app.sh"
            icon=$ICON_APP
            icon.color=$PEACH
            label.padding_right=0
)

sketchybar                             \
--add item front_app left              \
     --set front_app "${front_app[@]}" \
     --subscribe front_app front_app_switched space_change space_windows_change
