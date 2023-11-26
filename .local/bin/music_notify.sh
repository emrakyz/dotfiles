#!/bin/sh

song_info="$(mpc current)"

notify-send "Playing:" "$song_info"
