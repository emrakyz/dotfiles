#!/bin/bash
grep -v '^#' benimpaketler.txt | tr '\n' ' ' | sed 's/\ \ /\ /g'
emerge $DEPLIST
