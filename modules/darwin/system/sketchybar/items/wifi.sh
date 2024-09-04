#!/bin/env/bash

POPUP_OFF="sketchybar --set wifi popup.drawing=off"

wifi=(
  "${menu_defaults[@]}"
  label.drawing=off
  popup.align=right
  update_freq=5
  script="$PLUGIN_DIR/wifi.sh"
  --subscribe wifi wifi_change
                   mouse.clicked
                   mouse.exited
                   mouse.exited.global
)

sketchybar                                                                                            \
  --add item wifi right                                                                               \
  --set wifi "${wifi[@]}"                                                                             \
  --add item wifi.ssid popup.wifi                                                                     \
  --set wifi.ssid icon=􀅴                                                                              \
        label="SSID"                                                                                  \
        "${menu_item_defaults[@]}"                                                                    \
        click_script="open 'x-apple.systempreferences:com.apple.preference.network?Wi-Fi';$POPUP_OFF" \
  --add item wifi.ipaddress popup.wifi                                                                \
  --set wifi.ipaddress icon=􀆪                                                                         \
        label="IP Address"                                                                            \
        "${menu_item_defaults[@]}"                                                                    \
        click_script="echo \"$IP_ADDRESS\"|pbcopy;$POPUP_OFF"
