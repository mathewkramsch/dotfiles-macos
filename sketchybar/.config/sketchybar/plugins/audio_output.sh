#!/bin/sh

OUTPUT_DEVICE=$(SwitchAudioSource -c)

if [ "$OUTPUT_DEVICE" = "Jeremy’s AirPods Pro" ]; then
    sketchybar --set $NAME drawing=on icon=􀪷
elif [ "$OUTPUT_DEVICE" = "POD Go" ]; then
    sketchybar --set $NAME drawing=on icon=􀟑
elif [ "$OUTPUT_DEVICE" = "Fosi Audio" ]; then
    sketchybar --set $NAME drawing=on icon=􀝏
elif [ "$OUTPUT_DEVICE" = "MDR-1000X" ]; then
    sketchybar --set $NAME drawing=on icon=􀺹
else
    sketchybar --set $NAME drawing=off
fi
