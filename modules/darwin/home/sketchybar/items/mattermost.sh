#!/usr/bin/env sh
source "$CONFIG_DIR/icons.sh"

OPEN_MATTERMOST="open -a Mattermost"

sketchybar  --add   item mattermost right \
            --set   mattermost \
                    update_freq=60 \
                    script="$PLUGIN_DIR/mattermost.sh" \
                    icon.font.size=16 \
                    click_script="$OPEN_MATTERMOST" \
           --subscribe mattermost system_woke
