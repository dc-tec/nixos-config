# Load global styles, colors and icons
source "$CONFIG_DIR/defaults.sh"

control_center=(
  icon=$ICON_CONTROLCENTER
  label.drawing=off
  y_offset=1
  click_script="osascript -e 'tell application \"System Events\" to tell process \"Control Center\" to perform action \"AXPress\" of menu bar item 2 of menu bar 1'"
)

sketchybar --add item control_center right          \
           --set      control_center "${control_center[@]}"
