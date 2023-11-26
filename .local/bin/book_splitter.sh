#!/bin/sh

[ ! -f "$2" ] && printf "The first file should be the audio, the second should be the timecodes.\\n" && exit

echo "Enter the album/book title:"; read -r booktitle
echo "Enter the artist/author:"; read -r author
echo "Enter the publication year:"; read -r year

inputaudio="$1"
ext="${1##*.}"

# Get a safe file name from the book.
escbook="$(echo "$booktitle" | iconv -cf UTF-8 -t ASCII//TRANSLIT | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed "s/-\+/-/g;s/\(^-\|-\$\)//g")"

! mkdir -p "$escbook" &&
    echo "Do you have write access in this directory?" &&
    exit 1

# Get the total number of tracks from the number of lines.
total="$(wc -l < "$2")"

while read -r x || [ -n "$x" ];
do
    end="$(echo "$x" | cut -d' ' -f1)"
    file="$escbook/$(printf "%.2d" "$track")-$esctitle.$ext"
    if [ -n "$start" ]; then
        ffmpeg -i "$inputaudio" -nostdin -y -ss "$start" ${end:+-to "$end"} -vn -c:a libopus -b:a 96k "$file.opus"
        tag.sh -a "$author" -t "$title" -A "$booktitle" -n "$track" -N "$total" -d "$year" "$file"
    fi
    title="$(echo "$x" | cut -d' ' -f2-)"
    esctitle="$(echo "$title" | iconv -cf UTF-8 -t ASCII//TRANSLIT | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed "s/-\+/-/g;s/\(^-\|-\$\)//g")"
    track="$((track+1))"
    start="$end"
done < "$2"
