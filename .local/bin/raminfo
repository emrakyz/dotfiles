#!/bin/dash

while read -r key val _; do
    case $key in
        MemTotal:) total=$val;;
        MemAvailable:) available=$val;;
    esac
done < /proc/meminfo

usage=$(( (total - available) * 100 / total ))

echo "$usage"
