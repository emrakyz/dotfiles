#!/bin/bash
grep -v '^#' dependencies.txt | tr '\n' ' ' | sed 's/\ \ /\ /g'
emerge $DEPLIST
