# White-Pepper (`v1.1.0`)

**Interactive PyQt6 Desktop Scanner, Computer Vision & PDF Layout Suite** — paired with a standalone, zero-GUI headless backend repository in [`scripts/`](./scripts).

- **License**: Mozilla Public License 2.0 (`MPL-2.0`)
- **Author**: AceBurgundy (`Samadriansabalo99@gmail.com`)
- **Two-Part Repository Architecture**:
  - **Root (`white-pepper/`)**: Dark-themed PyQt6 interactive desktop application (`main.py`, `ui/`) with non-blocking `QThread` workers and live raster/PDF viewport previews.
  - **Headless Engine (`white-pepper/scripts/`)**: Standalone Git repository providing `scan_cli.py`, `process_cli.py`, `diagnostics_cli.py`, and the pure-Python `white_pepper` library (`PyQt6`-free) for custom frontends and automation.

---

## Key Capabilities (`v1.1.0`)

1. **14 Paper Size Presets + Custom Platen Regions (`mm` / `in`)**:
   - `full`, `a4`, `letter`, `legal` *(with safe hardware platen clamping and live UI feedback)*, `a5`, `a6`, `b5`, `executive`, `statement`, `photo-4x6`, `photo-5x7`, `index-3x5`, `id-card`, `receipt-half`, and `custom` (`Width × Height` + `Offset X / Y` + `Portrait / Landscape`).
   - Deterministic software bounding-box clipping (`fitz.Rect` for PDF streams; pixel slicing for raster streams) neutralizing eSCL `<pwg:ScanRegion>` firmware bugs.
2. **Full Optical & Image Adjustment Controls**:
   - Discrete optical DPIs (`75, 100, 200, 300, 600, 1200`), Color Modes (`color`, `grayscale`, `bw`), Scan Intents (`document`, `photo`, `text-and-graphic`, `preview`), Brightness/Contrast (`-100..100`), Rotation (`0°, 90°, 180°, 270°`), Whitespace Auto-Crop, and Multi-Format Export (`PNG`, `JPEG`, `TIFF`, `BMP`, `PDF`).
3. **Computer Vision & Virtual-Paper PDF Compiler**:
   - **ID-1 Cards**: Live 5×5" platen capture or batch deskewing with configurable edge inset, rounded corner radius (`3.18 mm` default), and `transparent` / `white` / `black` background compositing.
   - **Booklets**: Continuous spread capture and batch dual-page splitting (`LTR` / `RTL`), aspect-ratio thresholding, even-spread rotation, and RapidOCR upright orientation.
   - **PDF Compiler**: Compile images onto `auto`, `a4`, `letter`, `legal` (`612 × 1008 pt`), `a5`, `b5`, `photo-4x6`, `photo-5x7`, or `custom` virtual pages with margins, fit modes (`contain`, `fill`, `stretch`, `original`), JPEG compression, and PDF metadata.
4. **1:1 CLI ↔ PyQt6 Desktop Parity**:
   - Every command-line argument in `scripts/` has a matching interactive control across the five scrollable desktop tabs (**Flatbed Scanner**, **ID-1 Cards**, **Booklets**, **PDF Compiler**, **Diagnostics**).

---

## Quick Start

### Launch the PyQt6 Desktop Application
```powershell
python main.py
```

### Run Headless CLI Workflows (`scripts/`)
```powershell
python scripts/scan_cli.py flatbed --paper-size a4 --dpi 300 --format pdf
python scripts/scan_cli.py flatbed boy-gatas-receipts
python scripts/process_cli.py compile-pdf --input-dir D:\Pictures\Scanned --output-file D:\Pictures\Scanned\bundle.pdf --paper-size letter --margin-mm 10 --fit-mode contain
python scripts/diagnostics_cli.py --json
```
