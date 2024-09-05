#!/bin/bash

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting


CURRENT_APP=$(/run/current-system/sw/bin/yabai -m query --windows app --window | /etc/profiles/per-user/roelc/bin/jq -r '.app')
CURRENT_SID=$(/run/current-system/sw/bin/yabai -m query --spaces index --space | /etc/profiles/per-user/roelc/bin/jq -r '.index')
FRONT_APP_LABEL_COLOR="$(sketchybar --query space.$CURRENT_SID | /etc/profiles/per-user/roelc/bin/jq -r ".label.highlight_color")"
sketchybar --set $NAME label="$CURRENT_APP" label.color=$FRONT_APP_LABEL_COLOR
