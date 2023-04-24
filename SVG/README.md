# svg2png.sh

## SVG to PNG Converter

This script converts all SVG files in a given directory to PNG format using the `cairosvg` library.

### Prerequisites

This script requires the `cairosvg` library to be installed. You can install it using pip:

```bash
pip install cairosvg
```

### Usage

To use this script, navigate to the directory containing your SVG files and run:

```bash
./svg2png.sh input_dir
```

This will create a `png` subdirectory within the `input_dir` directory and convert all SVG files to PNG format using a resolution of 600 dpi.

### Example

Suppose you have the following directory structure:

```
input_dir/
├── file1.svg
├── file2.svg
└── file3.svg
```

To convert all SVG files in the `input_dir` directory to PNG format, run:

```bash
./svg2png.sh input_dir
```

This will create the following directory structure:

```
input_dir/
├── file1.svg
├── file2.svg
├── file3.svg
└── png/
    ├── file1.png
    ├── file2.png
    └── file3.png
```

* If you need to adjust the resolution of the output PNG files, you can modify the -d flag in the cairosvg command in the script.
