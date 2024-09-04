#!/bin/bash

# NEWMESSAGES=$(sqlite3 ~/Library/Messages/chat.db "SELECT text FROM message WHERE is_read=0 AND is_from_me=0 AND text!='' AND date_read=0" | wc -l | awk '{$1=$1};1')
NEWMESSAGES=$(sqlite3 ~/Library/Messages/chat.db "SELECT COUNT(guid) FROM message WHERE NOT(is_read) AND NOT(is_from_me) AND text !=''")

if [ $NEWMESSAGES = 0 ]; then
  sketchybar --set $NAME drawing=off
else
  sketchybar --set $NAME drawing=on label="$NEWMESSAGES"
fi
