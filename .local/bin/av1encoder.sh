#!/bin/dash

[ -z "$1" ] && exit 1

av1an -i "$1" \
      -e svt-av1 \
      -o av1_opus_${1%.*}.mkv \
      -w 2 \
      -m lsmash \
      --pix-format yuv420p10le \
      --video-params "--preset 0 --crf 42 --tune 0 --input-depth 10 --enable-overlays 1 --scd 1 --lookahead 120 --keyint 240 --tile-columns 2 --tile-rows 2 --film-grain 30 --film-grain-denoise 0 --lp 16 --pin 1 --color-range 0"



      #--video-params "--enable-hdr 1 --input-depth 10 --preset 0 --crf 29 --tune 0 --enable-overlays 1 --scd 1 --lookahead 120 --color-primaries 9 --transfer-characteristics 16 --matrix-coefficients 9 --chroma-sample-position 2 --content-light 1000,63 --film-grain 30 --film-grain-denoise 0 --lp 16 --pin 1 --color-range 0 --mastering-display G(0.265,0.690)B(0.150,0.060)R(0.680,0.320)WP(0.3127,0.3290)L(1000,0.0050) --tile-columns 2 --tile-rows 2 --keyint 240"


    # -a "-c:a libopus -b:a 160k"
