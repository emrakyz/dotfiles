#!/bin/dash

PID=$(pgrep -u $LOGNAME Hyprland)
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$PID/environ|cut -d= -f2-)

mailsync

NEWMAILS=$(find ~/.local/share/mail/*/*/new -type f)

[ -z "$NEWMAILS" ] && exit

count=$(echo "$NEWMAILS" | wc -l)

notify-send -u critical "You have $count new e-mails."
