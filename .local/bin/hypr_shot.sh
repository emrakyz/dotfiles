#!/bin/dash

geometry="$(slurp)"
sleep "1.5"
grim -g "${geometry}" - | swappy -f -
