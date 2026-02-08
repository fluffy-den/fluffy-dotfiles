#!/bin/bash

TARGET_INDEX=$1

# Get current focused workspace
CURRENT_WS=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true) | .name')

# Get list of active outputs sorted by rect.x (left-to-right)
OUTPUT=$(i3-msg -t get_outputs | jq -r '
  map(select(.active==true)) 
  | sort_by(.rect.x) 
  | .['"$TARGET_INDEX"'].name
')

if [ -z "$OUTPUT" ]; then
  notify-send "i3" "Invalid screen index: $TARGET_INDEX"
  exit 1
fi

# Move workspace to the target output
i3-msg "workspace $CURRENT_WS; move workspace to output $OUTPUT"
