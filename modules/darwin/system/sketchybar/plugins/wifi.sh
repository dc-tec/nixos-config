#!/bin/bash

# Loads defined colors
source "$CONFIG_DIR/defaults.sh"

IS_VPN=$(/usr/local/bin/piactl get connectionstate)
# IS_VPN="Disconnected"
# CURRENT_WIFI="$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I)"
CURRENT_WIFI="$(ipconfig getsummary en0)"
# IP_ADDRESS="$(ipconfig getifaddr en0)"
IP_ADDRESS="$(echo "$CURRENT_WIFI" | grep -o "yiaddr = .*" | sed 's/^yiaddr = //')"
SSID="$(echo "$CURRENT_WIFI" | grep -o "SSID : .*" | sed 's/^SSID : //' | tail -n 1)"
# CURR_TX="$(echo "$CURRENT_WIFI" | grep -o "lastTxRate: .*" | sed 's/^lastTxRate: //')"

if [[ $IS_VPN != "Disconnected" ]]; then
  ICON_COLOR=$HIGHLIGHT
  ICON=$ICON_WIFI_DISCONNECTED
elif [[ $SSID = "UniFi" ]]; then
  ICON_COLOR=$BASE
  ICON=$ICON_WIFI_CONNECTED
elif [[ $SSID != "" ]]; then
  ICON_COLOR=$BASE
  ICON=$ICON_WIFI_CONNECTED
elif [[ $CURRENT_WIFI = "AirPort: Off" ]]; then
  ICON=$ICON_WIFI_CONNECTED
else
  ICON_COLOR=$BASE
  ICON=$ICON_WIFI_ALERT
fi

render_bar_item() {
  sketchybar --set $NAME \
    icon.color=$ICON_COLOR \
    icon=$ICON
}

render_popup() {
  if [ "$SSID" != "" ]; then
    args=(
      --set wifi.ssid label="$SSID"
      --set wifi.ipaddress label="$IP_ADDRESS"
      click_script="printf $IP_ADDRESS | pbcopy;sketchybar --set wifi popup.drawing=toggle"
    )
  else
    args=(
      --set wifi.ssid label="Not connected"
      --set wifi.ipaddress label="No IP"
      )
  fi

  sketchybar "${args[@]}" >/dev/null
}

update() {
  render_bar_item
  render_popup
}

popup() {
  sketchybar --set "$NAME" popup.drawing="$1"
}

case "$SENDER" in
"routine" | "forced")
  update
  ;;
"mouse.clicked")
  popup toggle
  ;;
esac
