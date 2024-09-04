#!/bin/bash

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting


CURRENT_APP=$(yabai -m query --windows app --window | jq -r '.app')
CURRENT_SID=$(yabai -m query --spaces index --space | jq -r '.index')
FRONT_APP_LABEL_COLOR="$(sketchybar --query space.$CURRENT_SID | jq -r ".label.highlight_color")"
sketchybar --set $NAME label="$CURRENT_APP" label.color=$FRONT_APP_LABEL_COLOR
