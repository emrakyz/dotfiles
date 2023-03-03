#!/bin/sh

cd ~

export _JAVA_AWT_WM_NONREPARENTING=1
export LIBVA_DRIVER_NAME=nvidia
export GBM_BACKEND=nvidia-drm
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export WLR_NO_HARDWARE_CURSORS=1
export XDG_RUNTIME_DIR="/tmp/hyprland"
export SDL_VIDEODRIVER=wayland
export QT_SCREEN_SCALE_FACTORS="1;1"
export XCURSOR_SIZE=18

mkdir -p $XDG_RUNTIME_DIR
chmod 0700 $XDG_RUNTIME_DIR
exec dbus-launch Hyprland
