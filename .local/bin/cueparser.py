#!/bin/env python

import re
import sys

def extract_track_info(file_path):
    with open(file_path, 'r') as file:
        data = file.read()

    performer = re.search(r'PERFORMER "(.*?)"', data).group(1)

    indices = re.findall(r'INDEX 01 (\d{2}:\d{2}):', data)
    titles = re.findall(r'TITLE "(.*?)"', data)[1:] # Exclude album title

    tracks = []
    for index, title in zip(indices, titles):
        hour, minute = map(int, index.split(':'))
        timestamp = "{:02}:{:02}:{:02}".format(0, hour, minute)
        tracks.append(f'{timestamp} {performer} - {title}')

    return tracks

def main():
    if len(sys.argv) < 2:
        print("Please specify a .cue file.")
        return

    file_path = sys.argv[1]
    tracks = extract_track_info(file_path)
    for track in tracks:
        print(track)

if __name__ == "__main__":
    main()
