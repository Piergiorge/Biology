# svg2png.sh

* How to run:
```bash
find . -name "/path/to/input.svg" -exec bash -c 'cairosvg -d 600 -o "/path/to/output_dir/${0%.svg}.png" "$0"' {} \;
``` 


This will execute the Bash script and generate the following directory structure:

```bash
.
├── script.sh
├── svg
│   ├── image1.svg
│   ├── image2.svg
│   └── image3.svg
└── png
    ├── image1.png
    ├── image2.png
    └── image3.png
```
