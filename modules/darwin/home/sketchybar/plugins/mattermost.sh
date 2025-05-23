#!/usr/bin/env sh
source "$CONFIG_DIR/colors.sh"

STATUS_LABEL=$(lsappinfo info -only StatusLabel "Mattermost")
if [[ $STATUS_LABEL =~ \"label\"=\"([^\"]*)\" ]]; then
    LABEL="${BASH_REMATCH[1]}"

    if [[ $LABEL == "" ]]; then
        ICON_COLOR=$WHITE
    elif [[ $LABEL == "•" ]]; then
        ICON_COLOR=$GREEN
    elif [[ $LABEL =~ ^[0-9]+$ ]]; then
        ICON_COLOR=$RED
    else
        exit 0
    fi
else
  exit 0
fi

sketchybar --set $NAME label="${LABEL}" icon.color=${ICON_COLOR}
