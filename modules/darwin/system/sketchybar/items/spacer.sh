#!/bin/env/bash

spacer=(
  width=0
  icon.padding_left=0
  icon.padding_right=0
  padding_left=0
  padding_right=0
)

sketchybar \
  --add item spacer $1 \
  --set spacer "${spacer[@]}"
