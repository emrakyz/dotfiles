#!/bin/sh

word=$(wl-paste --primary)

librewolf "https://www.oxfordlearnersdictionaries.com/search/english/?q='$word'"
