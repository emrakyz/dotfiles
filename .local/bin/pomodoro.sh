#!/bin/dash

work_duration="52m"
short_break="17m"
long_break="35m"
session_count="0"

start_timer() {
        label="${1}"
        duration="${2}"
        next_duration="${3%m}"

        echo "${label}"
        timer "${duration}"
        notify-send "${label} session done. You have ${next_duration} minutes."
}

while true; do
        session_count="$((session_count + 1))"
        [ "$((session_count % 4))" -eq "0" ] && break_duration="${long_break}" || break_duration="${short_break}"

        start_timer "Work" "${work_duration}" "${break_duration}"
        start_timer "Break" "${break_duration}" "${work_duration}"
done
