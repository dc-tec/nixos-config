#!/usr/bin/env bash

# API key from https://www.weatherapi.com/my/
API_KEY="462eeb49a1b844f191f175554222607"
CITY="Den Bosch, Netherlands"
CITY="$(curl -s -m 5 ipinfo.io/loc)"

# first comment is description, second is icon number
WEATHER_ICONS_DAY=(
  [1000]= # Sunny/113
  [1003]= # Partly cloudy/116
  [1006]= # Cloudy/119
  [1009]= # Overcast/122
  [1030]= # Mist/143
  [1063]= # Patchy rain possible/176
  [1066]= # Patchy snow possible/179
  [1069]= # Patchy sleet possible/182
  [1072]= # Patchy freezing drizzle possible/185
  [1087]= # Thundery outbreaks possible/200
  [1114]= # Blowing snow/227
  [1117]= # Blizzard/230
  [1135]= # Fog/248
  [1147]= # Freezing fog/260
  [1150]= # Patchy light drizzle/263
  [1153]= # Light drizzle/266
  [1168]= # Freezing drizzle/281
  [1171]= # Heavy freezing drizzle/284
  [1180]= # Patchy light rain/293
  [1183]= # Light rain/296
  [1186]= # Moderate rain at times/299
  [1189]= # Moderate rain/302
  [1192]= # Heavy rain at times/305
  [1195]= # Heavy rain/308
  [1198]= # Light freezing rain/311
  [1201]= # Moderate or heavy freezing rain/314
  [1204]= # Light sleet/317
  [1207]= # Moderate or heavy sleet/320
  [1210]= # Patchy light snow/323
  [1213]= # Light snow/326
  [1216]= # Patchy moderate snow/329
  [1219]= # Moderate snow/332
  [1222]= # Patchy heavy snow/335
  [1225]= # Heavy snow/338
  [1237]= # Ice pellets/350
  [1240]= # Light rain shower/353
  [1243]= # Moderate or heavy rain shower/356
  [1246]= # Torrential rain shower/359
  [1249]= # Light sleet showers/362
  [1252]= # Moderate or heavy sleet showers/365
  [1255]= # Light snow showers/368
  [1258]= # Moderate or heavy snow showers/371
  [1261]= # Light showers of ice pellets/374
  [1264]= # Moderate or heavy showers of ice pellets/377
  [1273]= # Patchy light rain with thunder/386
  [1276]= # Moderate or heavy rain with thunder/389
  [1279]= # Patchy light snow with thunder/392
  [1282]= # Moderate or heavy snow with thunder/395
)

WEATHER_ICONS_NIGHT=(
  [1000]= # Clear/113
  [1003]= # Partly cloudy/116
  [1006]= # Cloudy/119
  [1009]= # Overcast/122
  [1030]= # Mist/143
  [1063]= # Patchy rain possible/176
  [1066]= # Patchy snow possible/179
  [1069]= # Patchy sleet possible/182
  [1072]= # Patchy freezing drizzle possible/185
  [1087]= # Thundery outbreaks possible/200
  [1114]= # Blowing snow/227
  [1117]= # Blizzard/230
  [1135]= # Fog/248
  [1147]= # Freezing fog/260
  [1150]= # Patchy light drizzle/263
  [1153]= # Light drizzle/266
  [1168]= # Freezing drizzle/281
  [1171]= # Heavy freezing drizzle/284
  [1180]= # Patchy light rain/293
  [1183]= # Light rain/296
  [1186]= # Moderate rain at times/299
  [1189]= # Moderate rain/302
  [1192]= # Heavy rain at times/305
  [1195]= # Heavy rain/308
  [1198]= # Light freezing rain/311
  [1201]= # Moderate or heavy freezing rain/314
  [1204]= # Light sleet/317
  [1207]= # Moderate or heavy sleet/320
  [1210]= # Patchy light snow/323
  [1213]= # Light snow/326
  [1216]= # Patchy moderate snow/329
  [1219]= # Moderate snow/332
  [1222]= # Patchy heavy snow/335
  [1225]= # Heavy snow/338
  [1237]= # Ice pellets/350
  [1240]= # Light rain shower/353
  [1243]= # Moderate or heavy rain shower/356
  [1246]= # Torrential rain shower/359
  [1249]= # Light sleet showers/362
  [1252]= # Moderate or heavy sleet showers/365
  [1255]= # Light snow showers/368
  [1258]= # Moderate or heavy snow showers/371
  [1261]= # Light showers of ice pellets/374
  [1264]= # Moderate or heavy showers of ice pellets/377
  [1273]= # Patchy light rain with thunder/386
  [1276]= # Moderate or heavy rain with thunder/389
  [1279]= # Patchy light snow with thunder/392
  [1282]= # Moderate or heavy snow with thunder/395
)

render_item() {
  if [ "$TEMP" = "" ]; then
    args=(--set $NAME icon="󰔄 " label.drawing=off)
  else
    args=(--set $NAME icon="$ICON" icon.font="0xProto:Bold:14.0" label="${TEMP}°" label.drawing=on)
  fi

  sketchybar "${args[@]}" >/dev/null
}

render_popup() {
  if [ "$TEMP" = "" ]; then
    args+=(--set weather.details label="N/A"
      click_script="sketchybar --set $NAME popup.drawing=off")
  else
    args+=(--set weather.details label="$CONDITION_TEXT, Humidity: $HUMIDITY% ($LOCATION)"
      click_script="sketchybar --set $NAME popup.drawing=off")
  fi

  sketchybar "${args[@]}" >/dev/null
}

update() {
  if [ "$CITY" != "" ]; then
    DATA=$(curl -s -m 5 "http://api.weatherapi.com/v1/current.json?key=$API_KEY&q=$CITY")
    CONDITION=$(echo $DATA | /etc/profiles/per-user/roelc/bin/jq -r '.current.condition.code')
    CONDITION_TEXT=$(echo $DATA | /etc/profiles/per-user/roelc/bin/jq -r '.current.condition.text')
    TEMP=$(echo $DATA | /etc/profiles/per-user/roelc/bin/jq -r '.current.temp_c | floor')
    FEELSLIKE=$(echo $DATA | /etc/profiles/per-user/roelc/bin/jq -r '.current.feelslike_f')
    HUMIDITY=$(echo $DATA | /etc/profiles/per-user/roelc/bin/jq -r '.current.humidity')
    IS_DAY=$(echo $DATA | /etc/profiles/per-user/roelc/bin/jq -r '.current.is_day')
    LAT=$(echo $DATA | /etc/profiles/per-user/roelc/bin/jq -r '.location.lat')
    LON=$(echo $DATA | /etc/profiles/per-user/roelc/bin/jq -r '.location.lon')
    LOCATION=$(echo $DATA | /etc/profiles/per-user/roelc/bin/jq -r '.location.name' && echo ', ' && echo $DATA | /etc/profiles/per-user/roelc/bin/jq -r '.location.country')

    [ "$IS_DAY" = "1" ] && ICON=${WEATHER_ICONS_DAY[$CONDITION]} || ICON=${WEATHER_ICONS_NIGHT[$CONDITION]}
    args=()
  fi

  render_item
  render_popup

  if [ "$SENDER" = "forced" ]; then
    sketchybar --set "$NAME"
  fi
}

popup() {
  sketchybar --set "$NAME" popup.drawing="$1"
}

case "$SENDER" in
"routine" | "forced" | "wifi_change")
  update
  ;;
"mouse.entered")
  popup on
  ;;
"mouse.exited" | "mouse.exited.global")
  popup off
  ;;
"mouse.clicked")
  popup toggle
  ;;
esac
