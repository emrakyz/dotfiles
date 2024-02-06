#!/bin/dash

[ -z "${1}" ] || [ ! -f "${1}" ] && exit "1"

XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
cache="${XDG_CACHE_HOME}/vidthumb"
index="${cache}/index.json"
movie="$(realpath "${1}")"

mkdir -p "${cache}"

[ -f "${index}" ] && thumbnail="$(jq -r ". \"${movie}\"" < "${index}")" && [ "${thumbnail}" != "null" ] && [ -f "${cache}/${thumbnail}" ] && echo "${cache}/${thumbnail}" && exit "0"

thumbnail="$(uuidgen).jpg"

ffmpegthumbnailer -i "${movie}" -o "${cache}/${thumbnail}" -s "0" 2> "/dev/null" || exit "1"

[ ! -f "${index}" ] && echo "{\"${movie}\": \"${thumbnail}\"}" > "${index}" || {
        json="$(jq -r --arg movie "${movie}" --arg thumbnail "${thumbnail}" '. + {($movie): $thumbnail}' < "${index}")"
        echo "${json}" > "${index}"
}

echo "${cache}/${thumbnail}"
