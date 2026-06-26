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

echo "Checking system dependencies for Termux..."

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
    echo "Installing missing dependencies via Termux pkg..."
    echo "Required packages: python, poppler, pillow"
    
    pkg update -y || { echo "Failed to update pkg"; exit 1; }
    pkg install -y python poppler || { echo "Failed to install system packages"; exit 1; }
    pkg install python-pillow || { echo "Failed to install Pillow"; exit 1; }
fi

# Enable strict error checking and trapping ONLY after setup is complete
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
    
    # Safe file counting using array globbing (avoids parsing ls)
    shopt -s nullglob
    valid_files=("$INPUT_DIR"/*.pdf "$INPUT_DIR"/*.cbz)
    FILE_COUNT=${#valid_files[@]}
    shopt -u nullglob

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

# Loop operation choice to handle user typos smoothly
while true; do
    echo "----------------------------------------"
    echo "Select operation:"
    echo "1) PDF to CBZ"
    echo "2) CBZ to PDF"
    read -p "Enter choice (1 or 2): " OPERATION

    if [ "$OPERATION" == "1" ] || [ "$OPERATION" == "2" ]; then
        break
    else
        echo "Invalid selection. Please enter 1 or 2."
    fi
done

echo "----------------------------------------"
echo "Executing conversion script..."

if [ "$OPERATION" == "1" ]; then
    if [ ! -f "pdf_to_cbz.py" ]; then
        echo "Error: Execution failed. 'pdf_to_cbz.py' is missing from the script directory!"
        exit 1
    fi
    python3 pdf_to_cbz.py "$INPUT_DIR" "$OUTPUT_DIR"
elif [ "$OPERATION" == "2" ]; then
    if [ ! -f "cbz_to_pdf.py" ]; then
        echo "Error: Execution failed. 'cbz_to_pdf.py' is missing from the script directory!"
        exit 1
    fi
    python3 cbz_to_pdf.py "$INPUT_DIR" "$OUTPUT_DIR"
fi
