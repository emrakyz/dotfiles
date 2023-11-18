#!/bin/sh

PASSWORD_STORE_DIR=${PASSWORD_STORE_DIR:-"$HOME/.password-store"}
ACTION_MENU='@@'

DMENU() {
    rofi -dmenu -i -l $1 -p "$2"
}

get_password() {
    find "$PASSWORD_STORE_DIR" -type f -name '*.gpg' | sed 's|.*/||; s/\.gpg$//' | DMENU 15 "My Passwords"
}

add_password() {
    NAME=$(DMENU 0 "New Password Name")
    [ -z "$NAME" ] && return
    PASSWORD=$(DMENU 0 "New Password for $NAME")
    [ -z "$PASSWORD" ] && return
    echo "$PASSWORD" | pass insert -f -m "$NAME"
    notify-send "'$NAME' added."
}

delete_password() {
    NAME=$(get_password)
    [ -z "$NAME" ] && return
    pass rm -f "$NAME"
    notify-send "'$NAME' deleted."
}

edit_password() {
    NAME=$(get_password)
    [ -z "$NAME" ] && exit
    FIELD=$(echo "Name\nPassword" | DMENU 2 "Edit")
    case "$FIELD" in
        "Name")
            NEW_NAME=$(DMENU 0 "New Password Name")
            [ -z "$NEW_NAME" ] && return
            pass mv "$NAME" "$NEW_NAME"
            notify-send "'$NAME' renamed to '$NEW_NAME'."
            ;;
        "Password")
            pass edit "$NAME"
            ;;
    esac
}

PASSWORD=$(get_password)
[ -z "$PASSWORD" ] && exit

case "$PASSWORD" in
    "$ACTION_MENU")
        ACTION=$(echo "Add\nDelete\nEdit" | DMENU 3 "Action")
        case "$ACTION" in
            "Add") add_password ;;
            "Delete") delete_password ;;
            "Edit") edit_password ;;
        esac
        ;;
    *)
        wl-copy $(pass show "$PASSWORD" | head -1) && sleep 45s && wl-copy -c
        ;;
esac
