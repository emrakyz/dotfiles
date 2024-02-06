#!/bin/dash

[ -z "${1}" ] && url="$(wl-paste --primary)" || url="${1}"

case "${url}" in
        *"mkv" | *"webm" | *"mp4" | *"youtube.com/watch"* | *"youtube.com/playlist"* | *"youtube.com/shorts"* | *"youtu.be"* | *"hooktube.com"* | *"bitchute.com"* | *"videos.lukesmith.xyz"* | *"odysee.com"*)
                setsid -f mpv -quiet "${url}" > "/dev/null" 2>&1
                ;;
        *"png" | *"jpg" | *"jpe" | *"jpeg" | *"gif" | *"webp")
                curl -sL "${url}" > "/tmp/$(echo "${url}" | sed "s/.*\///;s/%20/ /g")" && imv -f "/tmp/$(echo "${url}" | sed "s/.*\///;s/%20/ /g")" > "/dev/null" 2>&1 &
                ;;
        *"pdf" | *"cbz" | *"cbr")
                curl -sL "${url}" > "/tmp/$(echo "${url}" | sed "s/.*\///;s/%20/ /g")" && zathura "/tmp/$(echo "${url}" | sed "s/.*\///;s/%20/ /g")" > "/dev/null" 2>&1 &
                ;;
        *"mp3" | *"flac" | *"opus" | *mp3?source*)
                setsid -f mpv -quiet "${url}" > "/dev/null" 2>&1
                ;;
        *)
                [ -f "${url}" ] && setsid -f "${TERMINAL}" -e "${EDITOR}" "${url}" > "/dev/null" 2>&1 || setsid -f "${BROWSER}" "${url}" > "/dev/null" 2>&1
                ;;
esac
