#!/bin/dash

command -v locate > "/dev/null" || {
        notify-send "Locate not found. Installing..."
        doas emerge "sys-apps/mlocate"
} || {
        notify-send "Failed. Run the script once on terminal OR change doas permissions."
        exit "1"
}

[ -s "${HOME}/.config/.mymlocatepdf.db" ] || {
        notify-send "You have no database. Creating it..."
        disk_path="$(echo "" | rofi -dmenu -l "0" -p "Enter the disk path (e.g '/mnt/harddisk'): ")"
        doas updatedb -o "${HOME}/.config/.mymlocatepdf.db" -U "${disk_path}" || {
                notify-send "Failed. Run the script once on terminal OR change doas permissions."
                exit "1"
        }
}

video_files="$(locate -d "${HOME}/.config/.mymlocatepdf.db" -b -r '.*\.\(pdf\)$')"
chosen_file="$(echo "${video_files}" | sed 's|.*/||; s/\.[^.]*$//' | rofi -dmenu -p "Select PDF")"
zathura "$(echo "${video_files}" | grep -F "/${chosen_file}.")"
