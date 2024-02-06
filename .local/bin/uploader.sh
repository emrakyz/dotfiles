#!/bin/dash

is_compressible() {
        for f in "${@}"; do
                [ -d "${f}" ] && ! is_compressible "${f}"/* && return "1"
                case "${f##*.}" in
                        "jpg" | "jpeg" | "jxl" | "mkv" | "mp4" | "webm" | "mov" | "pdf" | "png" | "m4v" | "flv" | "avi") return "1" ;;
                esac
        done
        return "0"
}

upload_file() {
        LINK="$(curl -F"file=@${1}" "0x0.st")"
        echo "${LINK}\n${2:-}" | wl-copy
}

read -rp "Name: " ARCHIVE_BASENAME

[ "${1}" = "a" ] && {
        UUID="$(uuidgen)"
        shift
        FINAL_ARCHIVE="${ARCHIVE_BASENAME}.7z"
        COMPRESSION_LEVEL="-mx=9"

        for FILE in "${@}"; do
		is_compressible "${FILE}" || {
                        COMPRESSION_LEVEL="-mx=0"
                        break
		}
        done

        7z a -t7z -mhe=on -p"${UUID}" "${FINAL_ARCHIVE}" ${COMPRESSION_LEVEL} "${@}"

        upload_file "${FINAL_ARCHIVE}" "${UUID}" && notify-send "Uploading has finished. URL & Pass is on the clipboard."

        rm -f "${FINAL_ARCHIVE}"
} || {
        [ $# -ne "1" ] && {
                echo "Use 'a' option for more than one file."
                exit "1"
        }
        upload_file "${1}"
}
