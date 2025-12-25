#!/usr/bin/env bash
 
source "$CONFIG_DIR/colors.sh"

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

AEROSAPCE_WORKSPACE_FOCUSED_MONITOR=$(aerospace list-workspaces --monitor focused --empty no)
AEROSPACE_EMPTY_WORKESPACE=$(aerospace list-workspaces --monitor focused --empty)
DISPLAY_COUNT=$(aerospace list-monitors | wc -l | xargs)

if [ $DISPLAY_COUNT == 1 ]; then
  AEROSPACE_FOCUSED_MONITOR=1
else
  AEROSPACE_FOCUSED_MONITOR=$(aerospace list-monitors --focused | awk '{print $1}')
  AEROSPACE_FOCUSED_MONITOR=$(echo $displayMap | jq --arg nsscreen "$AEROSPACE_FOCUSED_MONITOR" -r '.[$nsscreen]')
fi

reload_workspace_icon() {
  apps=$(aerospace list-windows --workspace "$@" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
    done <<< "${apps}"
  else
    icon_strip=" —"
  fi

  sketchybar --animate sin 10 --set space.$@ label="$icon_strip"
}

if [ "$SENDER" = "aerospace_workspace_change" ]; then

  reload_workspace_icon "$AEROSPACE_PREV_WORKSPACE"
  reload_workspace_icon "$AEROSPACE_FOCUSED_WORKSPACE"

  # current workspace space border color
  sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE icon.highlight=true \
                         label.highlight=true \
                         background.border_color=$GREY

  # prev workspace space border color
  sketchybar --set space.$AEROSPACE_PREV_WORKSPACE icon.highlight=false \
                         label.highlight=false \
                         background.border_color=$BACKGROUND_2


  for i in $AEROSAPCE_WORKSPACE_FOCUSED_MONITOR; do
    sketchybar --set space.$i display=$AEROSPACE_FOCUSED_MONITOR
  done

  for i in $AEROSPACE_EMPTY_WORKESPACE; do
    sketchybar --set space.$i display=0
  done

  sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE display=$AEROSPACE_FOCUSED_MONITOR

fi
