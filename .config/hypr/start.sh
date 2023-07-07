#!/bin/sh

cd ~

export XDG_RUNTIME_DIR="/tmp/hyprland"
mkdir -p $XDG_RUNTIME_DIR
chmod 0700 $XDG_RUNTIME_DIR
exec dbus-launch --exit-with-session Hyprland
