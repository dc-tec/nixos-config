#!/usr/bin/env bash

TEXT=$(lsappinfo info -only StatusLabel "Mail" | grep -o '"label"="[0-9]*"' | awk -F'"' '{print $4}')

if [[ $TEXT -gt 0 ]]; then
  sketchybar -m --set $NAME drawing=on label="$TEXT"
else
  sketchybar -m --set $NAME drawing=off
fi
