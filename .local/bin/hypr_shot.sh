#!/bin/sh

geometry=$(slurp)
sleep 0.3
grim -g "$geometry" - | swappy -f -
