# Load global styles, colors and icons
source "$CONFIG_DIR/defaults.sh"

weather=(
  script="$PLUGIN_DIR/weather.sh"
  "${menu_defaults[@]}"
  popup.align=right
  update_freq=300
  icon.padding_right=0
  icon.color=$HIGHLIGHT
  updates=on
  click_script="sketchybar --set $NAME popup.drawing=toggle; open -a /System/Applications/Weather.app"
  --subscribe weather wifi_change
                      mouse.entered
                      mouse.exited
                      mouse.exited.global
)

sketchybar                                              \
  --add item weather right                              \
       --set weather "${weather[@]}"                    \
  --add item weather.details popup.weather              \
       --set weather.details "${menu_item_defaults[@]}" icon.drawing=off label.padding_left=0
