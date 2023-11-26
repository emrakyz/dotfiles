#!/bin/sh

# output_device=$(wpctl inspect @DEFAULT_AUDIO_SINK@ | grep -o "alsa_output.*[[:alnum:]]")
# audiodevice="--audio=$output_device.monitor"
videocodec="-c libx264rgb"
# audiocodec="-C libvorbis"
framerate="-r 60"
# colors="-x yuv420p"
codecparameter1="-p "crf=24""
codecparameter2="-p "preset=ultrafast""
codecparameter3="-p "tune=zerolatency""
codecparameter4="-p "cpu-used=8""
filename="-f $(date '+%y%m%d-%H%M-%S')"
extension=".mp4"

choice=$(echo "Start Recording\\nStop Recording" | rofi -dmenu -l 2)
case "$choice" in
	"Start Recording") wf-recorder $videocodec $audiodevice $audiocodec $muxer $framerate $colors $codecparameter1 $codecparameter2 $codecparameter3 $codecparameter4 $filename$extension;;
	"Stop Recording") doas killall wf-recorder;;
esac
