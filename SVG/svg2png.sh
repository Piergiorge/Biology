#!/bin/bash
# This script finds all SVG files in the current directory and converts them to PNG format using cairosvg
# The output PNG files are saved in a "png" subdirectory in the parent directory

# Use the find command to locate all SVG files in the current directory and execute a command on each file
find . -name "*.svg" -exec bash -c '
    # Use cairosvg to convert the SVG file to PNG format with a resolution of 600 dpi
    cairosvg -d 600 -o "../png/${0%.svg}.png" "$0"
' {} \;
