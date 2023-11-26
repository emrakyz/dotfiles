#!/bin/dash

XDG_CACHE_HOME="/home/emre/.cache"

while ! ping -c 1 9.9.9.9 > /dev/null 2>&1; do sleep 0.5; done

LOCATION="Menderes"

get_weather() {
  weather="$XDG_CACHE_HOME/weather.txt"
  curl "wttr.in/$LOCATION?format=%t" | grep -o '.*[[:digit:]]' > "$weather"
}

get_moon() {
  moon="$XDG_CACHE_HOME/moon.txt"
  curl "wttr.in/$LOCATION?format=%m" > "$moon"
}

get_updates() {
  update_file="$XDG_CACHE_HOME/updates.txt"
  doas emaint sync -a > /dev/null 2>&1 && emerge -up @world 2> /dev/null | grep -c '^\[ebuild' > "$update_file"
}

get_weather &
get_moon &
get_updates &
