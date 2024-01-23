#!/bin/bash

# Source directory where the font files are located
SOURCE_DIR="/Users/bomi/Downloads"

# Destination directory for fonts
DEST_DIR="/Library/Fonts"


# Temporary folder to store fonts
FONT_TEMP_DIR="$SOURCE_DIR/fonts"

# Check if the temporary font directory already exists
if [ -d "$FONT_TEMP_DIR" ]; then
    echo "Warning: Temporary font directory '$FONT_TEMP_DIR' already exists. It may contain fonts from a previous run."
fi

mkdir -p "$FONT_TEMP_DIR"

cd "$SOURCE_DIR" || exit

# Loop through all zip files in the source directory
for zip_file in *.zip; do
    # Check if there are any zip files
    if [ -e "$zip_file" ]; then
        # Unzip each file into its own directory
        unzip -d "${zip_file%.zip}" "$zip_file"
	# Remove the original zip file
        # rm "$zip_file"
    else
        echo "No zip files found in $SOURCE_DIR"
        exit 1
    fi
done

echo "Unzipping completed."


# Use find with while read to handle spaces in file names
find "$SOURCE_DIR" -type f \( -name "*.ttf" -o -name "*.otf" \) -print0 |
while IFS= read -r -d '' font_file; do
    # Extracting file name without path
    font_filename=$(basename "$font_file")

    echo "Copying '$font_filename' to '$FONT_TEMP_DIR/'"

    # Copy the font file to the temporary font directory
    cp -v "$font_file" "$FONT_TEMP_DIR/"
done

# Find all .ttf and .otf files in the temporary font directory
TEMP_FONT_FILES=("$FONT_TEMP_DIR"/*.ttf "$FONT_TEMP_DIR"/*.otf)

# Loop through the temporary font files
for temp_font_file in "${TEMP_FONT_FILES[@]}"; do
    # Extracting file name without path
    temp_font_filename=$(basename "$temp_font_file")

    echo "Processing font: $temp_font_filename"
    
    # Check if the file already exists in the destination directory
    if [ -e "$DEST_DIR/$temp_font_filename" ]; then
        # Compare file sizes and timestamps
        if cmp -s "$temp_font_file" "$DEST_DIR/$temp_font_filename"; then
            echo "Skipping $temp_font_filename (already exists in $DEST_DIR)"
            continue
        fi
    fi

    # Copy the font file to the destination directory
    sudo cp -r -v "$temp_font_file" "$DEST_DIR/"
done

# Update the font cache
sudo fc-cache -f -v

echo "Fonts copied and cache updated successfully."

