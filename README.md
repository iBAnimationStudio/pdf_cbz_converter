
# PDF-CBZ Converter
A lightweight, shell-and-python-based automation tool to batch convert **PDF files to CBZ (Comic Book Archive)** and vice versa. It works seamlessly across standard **Linux** environments and **Android (via Termux)**, automatically handling missing dependencies on its first run.
## Features
 * **Dual Conversion Mode:** Easily switch between PDF ➔ CBZ and CBZ ➔ PDF.
 * **Batch Processing:** Scans and converts all matching files in your chosen directory automatically.
 * **Multi-Platform Support:** Dedicated setup scripts for native Linux distros (apt) and Android terminal environments (Termux pkg).
 * **High-Quality Rendering:** Uses pdftoppm for fast, crisp 300 DPI JPEG extractions from PDFs.
 * **Auto-Dependency Setup:** Detects missing system tools (poppler, python3) and python libraries (Pillow), downloading them automatically if needed.
## Prerequisites & Architecture
The toolkit relies on a combination of lightweight Bash drivers and Python processing scripts:
```
├── cbz_to_pdf.py        # Python backend handling image extractions and compiling to PDF
├── pdf_to_cbz.py        # Python backend pulling high-res pages via pdftoppm into ZIP/CBZ format
├── converter_linux.sh   # Bash entrypoint for Linux (Debian/Ubuntu based systems)
└── converter_termux.sh  # Bash entrypoint for Termux on Android

```
## How to Run
### 1. Clone & Set Permissions
Clone this repository to your environment and navigate into the folder. Grant execution permissions to the shell scripts:
```bash
chmod +x converter_linux.sh converter_termux.sh

```
### 2. Execute the Controller
#### On Linux (Ubuntu/Debian):
```bash
./converter_linux.sh

```
#### On Android (Termux):
```bash
./converter_termux.sh

```
### 3. Follow the Prompts
 1. **Directories:** Enter your custom path input/output locations or hit Enter to use the current folder.
 2. **Select Operation:** Choose 1 for PDF to CBZ, or 2 for CBZ to PDF.
## Technical Details
 * **PDF ➔ CBZ:** Spawns a pdftoppm subprocess using flags [-jpeg -jpegopt quality=90 -r 300] for optimal comic/manga styling, storing files uncompressed (ZIP_STORED) inside the target archive to guarantee fast rendering speeds on typical comic readers.
 * **CBZ ➔ PDF:** Unpacks the archive file structure using zipfile, sorts visual files chronologically, targets image signatures (.jpg, .jpeg, .png), shifts color-spaces into unified RGB layers via Pillow, and streams pages sequentially into a single target vector layer.
