import sys
import subprocess
import tempfile
import zipfile
import shutil
from pathlib import Path

if len(sys.argv) < 3:
    print("Usage: python3 pdf_to_cbz.py <input_dir> <output_dir>")
    sys.exit(1)

INPUT_DIR = Path(sys.argv[1])
OUTPUT_DIR = Path(sys.argv[2])
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

for pdf_file in sorted(INPUT_DIR.glob("*.pdf")):
    print(f"Processing: {pdf_file.name}")
    temp_dir = Path(tempfile.mkdtemp())
    try:
        prefix = temp_dir / "page"
        subprocess.run(["pdftoppm", "-jpeg", "-jpegopt", "quality=90", "-r", "300", str(pdf_file), str(prefix)], check=True)
        cbz_file = OUTPUT_DIR / f"{pdf_file.stem}.cbz"
        with zipfile.ZipFile(cbz_file, "w", compression=zipfile.ZIP_STORED) as cbz:
            for image in sorted(temp_dir.glob("page-*.jpg")):
                cbz.write(image, image.name)
        print(f"Created: {cbz_file.name}")
    finally:
        shutil.rmtree(temp_dir)
print("PDF to CBZ conversion complete.")
