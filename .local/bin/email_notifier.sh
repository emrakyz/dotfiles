#!/bin/dash

mailsync

NEWMAILS="$(find '/home/*/.local/share/mail/*/*/new' -type f)"

[ -z "${NEWMAILS}" ] && exit

count="$(printf "%s\n" "${NEWMAILS}" | wc -l)"

notify-send -u critical "You have ${count} new e-mails."
