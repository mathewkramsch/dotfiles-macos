#!/usr/bin/env sh
STATUS_LABEL=$(lsappinfo info -only StatusLabel "Thunderbird")
ICON_PADDING_RIGHT=12
DRAWING=false
if [[ $STATUS_LABEL == '"StatusLabel"={ "label"=kCFNULL }' ]]; then
    DRAWING=false
elif [[ $STATUS_LABEL =~ \"label\"=\"([^\"]*)\" ]]; then
    LABEL="${BASH_REMATCH[1]}"
    if [[ $LABEL == "" ]]; then
        DRAWING=false
    elif [[ $LABEL == "•" ]]; then
        ICON_PADDING_RIGHT=4
        DRAWING=true
    elif [[ $LABEL =~ ^[0-9]+$ ]]; then
        ICON_PADDING_RIGHT=4
        DRAWING=true
    else
        exit 0
    fi
else
  exit 0
fi

sketchybar --set $NAME label="${LABEL}" icon.padding_right=${ICON_PADDING_RIGHT} drawing=$DRAWING