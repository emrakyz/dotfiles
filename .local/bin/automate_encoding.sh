#!/bin/dash

[ -z "$1" ] && exit 1

for crf_value in $(seq 20 42); do
    av1an -i "$1" \
          -e svt-av1 \
	  -w 2 \
          -m lsmash \
          --pix-format yuv420p10le \
          --video-params "--preset 0 --crf ${crf_value} --tune 0 --input-depth 10 --enable-overlays 1 --scd 1 --lookahead 120 --keyint 240 --tile-columns 2 --tile-rows 2 --film-grain 0 --film-grain-denoise 0 --lp 16 --pin 1 --color-range 0" \
          -o av1_opus_myvideo_crf${crf_value}.mkv
done
