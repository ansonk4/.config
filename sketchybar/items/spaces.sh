#!/bin/sh

#SPACE_ICONS=("1" "2" "3" "4")

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)

sketchybar --add event aerospace_workspace_change

# map aerospace display id to stretchbar display id
displayMap=$(swift -e '
  import Cocoa
  var displayMap : [Int: UInt32] = [:]
  for (nsscreenid, screen) in NSScreen.screens.enumerated() {
      if let directdisplayid = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? UInt32 {
          displayMap[nsscreenid+1] = directdisplayid
      }
  }
  let jsonCompatibleDict = Dictionary(uniqueKeysWithValues:
      displayMap.map { (key, value) in (String(key), value) }
  )

  if let jsonData = try? JSONSerialization.data(withJSONObject: jsonCompatibleDict, options: .prettyPrinted),
     let jsonString = String(data: jsonData, encoding: .utf8) {
      print(jsonString)
  }')

for m in $(aerospace list-monitors | awk '{print $1}'); do
  displayId=$(echo $displayMap | jq --arg nsscreen "$m" -r '.[$nsscreen]')
  for i in $(aerospace list-workspaces --monitor $m); do
    sid=$i
    space=(
      space="$sid"
      icon="$sid"
      icon.highlight_color=$RED
      icon.padding_left=10
      icon.padding_right=10
      display=$displayId
      padding_left=2
      padding_right=2
      label.padding_right=20
      label.color=$GREY
      label.highlight_color=$WHITE
      label.font="sketchybar-app-font:Regular:16.0"
      label.y_offset=-1
      background.color=$BACKGROUND_1
      background.border_color=$BACKGROUND_2
      script="$PLUGIN_DIR/space.sh"
    )

    sketchybar --add space space.$sid left \
               --set space.$sid "${space[@]}" \
               --subscribe space.$sid mouse.clicked

    apps=$(aerospace list-windows --workspace $sid | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

    icon_strip=" "
    if [ "${apps}" != "" ]; then
      while read -r app
      do
        icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
      done <<< "${apps}"
    else
      icon_strip=" —"
    fi

    sketchybar --set space.$sid label="$icon_strip"
  done

  for i in $(aerospace list-workspaces --monitor $m --empty); do
    sketchybar --set space.$i display=0
  done
  
done


space_creator=(
  icon=􀆊
  icon.font="$FONT:Heavy:16.0"
  padding_left=10
  padding_right=8
  label.drawing=off
  display=active
  #click_script='yabai -m space --create'
  script="$PLUGIN_DIR/space_windows.sh"
  #script="$PLUGIN_DIR/aerospace.sh"
  icon.color=$WHITE
)


sketchybar --add item space_creator left               \
           --set space_creator "${space_creator[@]}"   \
           --subscribe space_creator aerospace_workspace_change

