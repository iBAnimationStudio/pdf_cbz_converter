#!/bin/bash

# Function to handle errors and exit gracefully
error_handler() {
    local exit_code=$?
    echo "----------------------------------------"
    echo "Error: Script failed at line $1 with exit code $exit_code."
    echo "Terminating execution."
    echo "----------------------------------------"
    exit "$exit_code"
}

echo "Checking system dependencies for Linux..."

ALL_INSTALLED=true

if ! command -v pdftoppm &> /dev/null; then
    ALL_INSTALLED=false
fi

if ! command -v python3 &> /dev/null; then
    ALL_INSTALLED=false
else
    if ! python3 -c "import PIL" &> /dev/null; then
        ALL_INSTALLED=false
    fi
fi

if [ "$ALL_INSTALLED" = true ]; then
    echo "All dependencies are installed. Skipping setup."
else
    echo "Installing missing dependencies via apt..."
    echo "Required packages: python3, python3-pip, poppler-utils, Pillow"
    
    sudo apt-get update -y || { echo "Failed to update package lists"; exit 1; }
    sudo apt-get install -y python3 python3-pip poppler-utils || { echo "Failed to install system packages"; exit 1; }
    pip3 install Pillow --break-system-packages 2>/dev/null || pip3 install Pillow || { echo "Failed to install Pillow"; exit 1; }
fi

# Enable strict error checking and trapping AFTER setup is complete
set -e
trap 'error_handler $LINENO' ERR

echo "----------------------------------------"
while true; do
    read -p "Enter input directory path (leave empty for current path): " INPUT_DIR
    [ -z "$INPUT_DIR" ] && INPUT_DIR="."

    if [ ! -d "$INPUT_DIR" ]; then
        echo "Error: Directory '$INPUT_DIR' does not exist. Try again."
        echo "----------------------------------------"
        continue
    fi

    echo "Scanning '$INPUT_DIR' for PDF and CBZ files..."
    
    # Temporarily disable error trapping for the file check
    set +e
    FILE_COUNT=$(ls -1 "$INPUT_DIR"/*.pdf "$INPUT_DIR"/*.cbz 2>/dev/null | wc -l)
    set -e

    if [ "$FILE_COUNT" -eq 0 ]; then
        echo "Error: No recognized files (PDF/CBZ) found in '$INPUT_DIR'."
        echo "Please select a correct directory with valid files inside."
        echo "----------------------------------------"
        continue
    fi
    
    echo "Found $FILE_COUNT valid file(s). Ready to process."
    break
done

echo "----------------------------------------"
read -p "Enter output directory path (leave empty for current path): " OUTPUT_DIR
[ -z "$OUTPUT_DIR" ] && OUTPUT_DIR="."

echo "----------------------------------------"
echo "Select operation:"
echo "1) PDF to CBZ"
echo "2) CBZ to PDF"
read -p "Enter choice (1 or 2): " OPERATION

echo "----------------------------------------"
echo "Executing conversion script..."

if [ "$OPERATION" == "1" ]; then
    python3 pdf_to_cbz.py "$INPUT_DIR" "$OUTPUT_DIR"
elif [ "$OPERATION" == "2" ]; then
    python3 cbz_to_pdf.py "$INPUT_DIR" "$OUTPUT_DIR"
else
    echo "Invalid selection. Exiting."
    exit 1
fi
