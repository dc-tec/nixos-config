#!/usr/bin/env sh
source "$CONFIG_DIR/icons.sh"

OPEN_MAIL="open -a Mail"

sketchybar  --add   item mail right \
            --set   mail \
                    update_freq=60 \
                    script="$PLUGIN_DIR/mail.sh" \
                    padding_left=15  \
                    icon.font.size=16 \
                    click_script="$OPEN_MAIL" \
           --subscribe mail system_woke
