#!/usr/bin/env bash

render_item() {
  sketchybar --set $NAME label="$(date "+%I:%M %p")" \
             --set date icon.drawing=$drawing
}

get_events() {
  if which "icalBuddy" &>/dev/null; then
    drawing="off"
    input=$(/opt/homebrew/bin/icalBuddy -ec 'Found in Natural Language,CCSF' -npn -nc -iep 'datetime,title' -po 'datetime,title' -eed -ea -n -li 4 -ps '|: |' -b '' eventsToday)
    currentTime=$(date '+%I:%M %p')

    if [ -n "$input" ]; then
      IFS='^' read -ra events <<< "$input"
      for anEvent in "${events[@]}"; do
        IFS='^' read -ra eventItems <<< "$anEvent"
        eventTime=${eventItems[0]}
        if [ "$eventTime" '>' "$currentTime" ]; then
          theEvent="$anEvent"
          drawing="on"
          break
        fi
      done
    else
      theEvent="No events today"
    fi
  else
    theEvent="Please install icalBuddy → brew install ical-buddy."
  fi
}

update() {
  get_events
  render_item
}

popup() {
  get_events
  sketchybar --set clock.next_event label="$theEvent" \
             --set "$NAME" popup.drawing="$1"
}

case "$SENDER" in
"routine" | "forced")
  update
  ;;
"mouse.entered")
  popup on
  ;;
"mouse.exited" | "mouse.exited.global")
  popup off
  ;;
esac
