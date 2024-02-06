#!/bin/sh

while ! ping -c "1" "9.9.9.9" > "/dev/null" 2>&1; do sleep "0.5"; done

URL="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"
TEMP="$(mktemp)"
HOSTS="/etc/hosts"

correction() {
        grep -oE '^0[^ ]+ [^ ]+' |
                grep -vF '0.0.0.0 0.0.0.0' |
                sed "/0.0.0.0 a.thumbs.redditmedia.com/,+66d" > "${TEMP}"
}

control() {
        grep -vxFf "${HOSTS}" "${TEMP}"
}

curl -s "${URL}" | correction

NEWHOSTS="$(control | wc -l)"

[ "$(wc -l < "${HOSTS}")" -lt "10" ] && echo " " >> "${HOSTS}"
control >> "${HOSTS}"

notify-send "${NEWHOSTS} new hosts added"

rm -f "${TEMP}"
