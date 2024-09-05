# Load global styles, colors and icons
source "$CONFIG_DIR/defaults.sh"

messages=(
  "${notification_defaults[@]}"
  icon=$ICON_MESSAGES
  background.color=$HIGHLIGHT_10
  label.color=$HIGHLIGHT
  icon.color=$HIGHLIGHT
  updates=on
  script="$PLUGIN_DIR/messages.sh"
  click_script="open -a /System/Applications/Messages.app"
)

sketchybar --add item  messages right            \
           --set       messages "${messages[@]}" \
           --subscribe messages front_app_switched
