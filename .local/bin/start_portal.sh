#!/bin/dash

killall "xdg-desktop-portal" "xdg-desktop-portal-hyprland" "xdg-desktop-portal-wlr"
sleep "2"
"/usr/libexec/xdg-desktop-portal-hyprland" &
sleep "2"
"/usr/libexec/xdg-desktop-portal" &
