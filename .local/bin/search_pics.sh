#!/bin/dash

pic_files="$(locate -d "${HOME}/.config/.mymlocate.db" -b -r '.*\.\(jpeg\|jpg\|png\|webp\|JPEG\|JPG\|PNG\|WEBP\)$')"
#chosen_file="$(echo "${pic_files}" | sed 's|.*/||; s/\.[^.]*$//' | rofi -dmenu -p "Select Video")"

echo "${pic_files}" | xargs -d '\n' -s "2092340"

#selected_pic="$(echo "${pic_files}" | grep -F "/${chosen_file}.")"
#imv "${selected_pic}"
