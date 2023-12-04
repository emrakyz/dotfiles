#!/bin/dash

CURRENT="$(pgrep -af mpvpaper | sed 's/.* //')"

{ [ -z "$CURRENT" ] && NEW=$(find "$XDG_DATA_HOME/wallpapers" -type f | shuf -n 1)
} || NEW=$(find "$XDG_DATA_HOME/wallpapers" -type f ! -name "${CURRENT##*/}" | shuf -n 1)

pkill mpvpaper
mpvpaper -o "--loop --no-audio --vo=libmpv" DP-2 "$NEW"
