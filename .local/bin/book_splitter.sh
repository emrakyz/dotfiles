#!/bin/dash

[ -f "${2}" ] || printf 'The first file should be the audio, the second should be the timecodes.\n' && exit

printf "Enter the album/book title:\n"
read -r "booktitle"
printf "Enter the artist/author:\n"
read -r "author"
printf "Enter the publication year:\n"
read -r "year"

inputaudio="${1}"
ext="${1##*.}"
escbook="$(printf "%s\n" "${booktitle}" | iconv -cf UTF-8 -t ASCII//TRANSLIT |
	tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' |
	sed "s/-\+/-/g;s/\(^-\|-\$\)//g")"

mkdir -p "${escbook}" || printf "Do you have write access in this directory?\n" && exit "1"

total="$(wc -l < "${2}")"

while read -r x || [ -n "${x}" ]; do
	end="$(printf "%s\n" "${x}" | cut -d' ' -f1)"
	file="${escbook}/$(printf "%.2d" "${track}")-${esctitle}.${ext}"

	[ -n "${start}" ] && {
	ffmpeg -i "${inputaudio}" -nostdin -y -ss "${start}" ${end:+-to "$end"} -vn -c:a libopus -b:a 96k "${file}.opus"
	tag.sh -a "${author}" -t "${title}" -A "${booktitle}" -n "${track}" -N "${total}" -d "${year}" "${file}"
	}

	title="$(printf "%s\n" "${x}" | cut -d' ' -f2-)"
	esctitle="$(printf "%s\n" "${title}" | iconv -cf UTF-8 -t ASCII//TRANSLIT | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed "s/-\+/-/g;s/\(^-\|-\$\)//g")"
	track="$(( track + 1 ))"
	start="${end}"
done < "${2}"
