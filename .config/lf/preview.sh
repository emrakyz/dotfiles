#!/bin/dash

file=$1
w=$2
h=$3
x=$4
y=$5

CACHE_DIR="$XDG_CACHE_HOME/lf"
mkdir -p "$CACHE_DIR"

cache_filename() {
    echo "$CACHE_DIR/$(basename "$file")_$(stat -c %Y "$file")"
}

filetype="$(file -Lb --mime-type "$file")"
CACHE_FILE="$(cache_filename)"

display() {
    kitty +kitten icat --silent --stdin no --transfer-mode file --place "${w}x${h}@${x}x${y}" "$1" < /dev/null > /dev/tty
}

case "$filetype" in
    text/*)
        bat --style=plain --color=always --line-range :35 "$file"
        ;;
    image/*)
	display $file
	;;
    video/*)
        [ -f "$CACHE_FILE" ] || { thumbnail="$(thumbnail_creator.sh "$file")" && cp "$thumbnail" "$CACHE_FILE"; }
        display "$CACHE_FILE"
        ;;
    audio/*)
	mediainfo $file
	;;
    application/pdf)
        CACHE_FILE="${CACHE_FILE}.jpg"
        [ -f "$CACHE_FILE" ] || pdftoppm -jpeg -f 1 -singlefile "$file" "${CACHE_FILE%.jpg}"
        display "$CACHE_FILE"
        ;;
    application/gzip|application/x-xz|application/x-bzip2)
	tar -tf $file
	;;
    application/zip)
	unzip -l $file | awk '{print $4}'
	;;
    application/7z)
	7z -l $file | awk '{print $4}'
	;;
esac

exit 1
