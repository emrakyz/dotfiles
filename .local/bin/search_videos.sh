#!/bin/sh

command -v locate > "/dev/null" || {
        notify-send "Locate not found. Installing..."
        doas emerge "sys-apps/mlocate"
} || {
        notify-send "Failed. Run the script once on terminal OR change sudo permissions."
        exit "1"
}

[ -s "${HOME}/.config/.mymlocate.db" ] || {
        notify-send "You have no database. Creating it..."
        disk_path="$(echo "" | rofi -dmenu -l "0" -p "Enter the disk path (e.g '/mnt/harddisk'): ")"
        doas updatedb -o "${HOME}/.config/.mymlocate.db" -U "${disk_path}" || {
                notify-send "Failed. Run the script once on terminal OR change doas permissions."
                exit "1"
        }
}

video_files="$(locate -d "${HOME}/.config/.mymlocate.db" -b -r '.*\.\(mp4\|mkv\|webm\|mov\|m4v\|wmv\|flv\|avi\|gif\)$')"
chosen_file="$(echo "${video_files}" | sed 's|.*/||; s/\.[^.]*$//' | rofi -dmenu -p "Select Video")"
#chosen_file=$(echo "${video_files}" | sed 's|.*/||; s/\.[^.]*$//' | shuf -n 1)

selected_video="$(printf "%s\n" "${video_files}" | grep -F "/${chosen_file}.")"

mpv "${selected_video}"
CHOICE="$(printf "Yes\nNo" | rofi -dmenu -l "2")"

[ "${CHOICE}" = "Yes" ] && rm -iv "${selected_video}"
