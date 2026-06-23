import sys
import tempfile
import zipfile
import shutil
from pathlib import Path
from PIL import Image

if len(sys.argv) < 3:
    print("Usage: python3 cbz_to_pdf.py <input_dir> <output_dir>")
    sys.exit(1)

INPUT_DIR = Path(sys.argv[1])
OUTPUT_DIR = Path(sys.argv[2])
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

for cbz_file in sorted(INPUT_DIR.glob("*.cbz")):
    print(f"Processing: {cbz_file.name}")
    temp_dir = Path(tempfile.mkdtemp())
    try:
        with zipfile.ZipFile(cbz_file, "r") as cbz:
            cbz.extractall(temp_dir)
        image_paths = sorted([p for p in temp_dir.rglob("*") if p.suffix.lower() in ('.jpg', '.jpeg', '.png')])
        if not image_paths:
            continue
        images = [Image.open(img).convert("RGB") for img in image_paths]
        pdf_file = OUTPUT_DIR / f"{cbz_file.stem}.pdf"
        images[0].save(pdf_file, save_all=True, append_images=images[1:])
        print(f"Created: {pdf_file.name}")
    finally:
        shutil.rmtree(temp_dir)
print("CBZ to PDF conversion complete.")
