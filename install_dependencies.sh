#!/bin/bash
DEPLIST="tr '\n' ' ' < dependencies.txt"
emerge $DEPLIST
