#!/bin/dash

LAST_SERVER_FILE="/tmp/last_server_wg"
action="$(echo "Up\nDown" | rofi -dmenu -i -l "2" -p "VPN Action")"

servers="$(doas find "/etc/wireguard" -type f -name '*.conf' -exec basename {} .conf \;)"
server_list="${servers}"

[ "${action}" = "Up" ] && {
        selected_server="$(printf "%s\n" "${server_list}" | rofi -dmenu -i -l "10" -p "Server")"
        doas wg-quick up "${selected_server}" && {
                printf "%s\n" "${selected_server}" > "${LAST_SERVER_FILE}"
                notify-send "Wireguard" "Connected to ${selected_server}"
        }
}

[ "$action" = "Down" ] && [ -f "${LAST_SERVER_FILE}" ] && {
        doas wg-quick down "$(cat "${LAST_SERVER_FILE}")" && {
                rm -f "${LAST_SERVER_FILE}"
                notify-send "Wireguard" "Disconnected"
        }
}
