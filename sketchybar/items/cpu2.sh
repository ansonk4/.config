#!/bin/bash
cpu2_top=(
  label.font=\"$FONT:Semibold:7\"
  label=CPU
  icon.drawing=off
  width=0
  padding_right=15
  y_offset=6
)

cpu2_percent=(
  label.font=\"$FONT:Heavy:12\"
  label=CPU
  y_offset=-4
  padding_right=15
  width=55
  icon.drawing=off
  update_freq=4
  mach_helper=\"$HELPER\"
)

cpu2_sys=(
  width=0
  graph.color=$RED
  graph.fill_color=$RED
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
)

cpu2_user=(
  graph.color=$BLUE
  label.drawing=off
  icon.drawing=off
  background.height=30
  background.drawing=on
  background.color=$TRANSPARENT
)


sketchybar --add item cpu2.top left             \
           --set cpu2.top "${cpu2_top[@]}"         \
                                                 \
           --add item cpu2.percent left          \
           --set cpu2.percent "${cpu2_percent[@]}" \
                                                 \
           --add graph cpu2.sys left 75          \
           --set cpu2.sys "${cpu2_sys[@]}"         \
                                                 \
           --add graph cpu2.user left 75         \
           --set cpu2.user "${cpu2_user[@]}"