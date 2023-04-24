#!/bin/bash

# Check if input directory was provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 input_dir"
  exit 1
fi

# Check if input directory exists
if [ ! -d "$1" ]; then
  echo "Error: Input directory not found."
  exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$1/png"

# Use the find command to locate all SVG files in the input directory and execute a command on each file
find "$1" -name "*.svg" -execdir bash -c '
    # Use cairosvg to convert the SVG file to PNG format with a resolution of 600 dpi
    cairosvg -d 600 -o "./png/${0%.svg}.png" "$0"
' {} \;
