#!/usr/bin/env sh
CURRENT_COVER=$(osascript -e 'tell application "Spotify" to return artwork url of current track')

curl -s --max-time 20 "$CURRENT_COVER" -o /tmp/cover.jpg

next ()
{
  osascript -e 'tell application "Spotify" to play next track'
}

back () 
{
  osascript -e 'tell application "Spotify" to play previous track'
}

play () 
{
  osascript -e 'tell application "Spotify" to playpause'
}

update ()
{
  PLAYING=1
  if [ "$(echo "$INFO" | jq -r '.["Player State"]')" = "Playing" ]; then
    PLAYING=0
    TRACK="$(echo "$INFO" | jq -r .Name | cut -c1-20)"
    ARTIST="$(echo "$INFO" | jq -r .Artist | cut -c1-20)"
    ALBUM="$(echo "$INFO" | jq -r .Album | cut -c1-20)"
  fi

  args=()
  if [ $PLAYING -eq 0 ]; then
    if [ "$ARTIST" == "" ]; then
      args+=(--set spotify.name label="$TRACK  •  $ALBUM" drawing=on \
             --set spotify.album_cover drawing=on)
    else
      args+=(--set spotify.name label="$TRACK  •  $ARTIST" drawing=on \
             --set spotify.album_cover drawing=on)
    fi
    args+=(--set spotify.play icon=􀊆)
  else
    args+=(--set spotify.name drawing=off \
           --set spotify.name popup.drawing=off \
           --set spotify.album_cover drawing=off)
  fi
  sketchybar -m "${args[@]}"
}

mouse_clicked () {
  case "$NAME" in
    "spotify.next") next
    ;;
    "spotify.back") back
    ;;
    *) exit
    ;;
  esac
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  "forced") exit
  ;;
  *) update
  ;;
esac

sketchybar --set spotify.album_cover \
             label.drawing=off \
             icon.drawing=off \
             padding_left=12 \
             padding_right=0 \
             background.image.scale=0.03 \
             background.image.drawing=on \
             background.color=$TRANSPARENT \
             background.image="/tmp/cover.jpg"  \
           --set spotify_group drawing=on\