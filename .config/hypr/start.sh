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
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM=wayland
export ANV_QUEUE_THREAD_DISABLE=1
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export MOZ_DBUS_REMOTE=1

mkdir -p $XDG_RUNTIME_DIR
chmod 0700 $XDG_RUNTIME_DIR
exec dbus-launch Hyprland
