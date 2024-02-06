#!/bin/dash

realesrgan-ncnn-vulkan -i "${1}" \
        -o "$(basename "${1}".png)" \
        -s "4" \
        -t "0" \
        -n "realesrgan-x4plus" \
        -g "0" \
        -j "1:2:2" \
        -f "png"
