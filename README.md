# Digital Steganography Forensics Project

Steganography detection and hidden data extraction toolkit for digital forensics analysis.

## Project Structure

```
stego-forensics-project/
├── datasets/                 # Input datasets (images, audio, videos)
├── extracted/               # Extracted hidden data
├── reports/                 # Analysis reports and visualizations
│   ├── bitplanes/           # Bit-plane extraction outputs
│   ├── spectrograms/        # Audio spectrogram comparisons
│   └── detection_report.txt # Consolidated forensic report
├── scripts/                 # Python analysis scripts
├── tools/                   # External tools (StegExpose)
├── run_scan.sh              # Main detection pipeline
├── run_extract.sh           # Main extraction pipeline
├── setup.sh                 # Installation script
└── requirements.txt         # Python dependencies
```

## Installation

```bash
chmod +x setup.sh
./setup.sh
```

This installs all system dependencies, creates a Python virtual environment, and installs required packages.

## Dataset Setup

```bash
chmod +x ingest-dataset.sh
./ingest-dataset.sh
```

This loads sample datasets into the `datasets/` directory.

## Running the Project

### Full Detection Scan

```bash
source venv/bin/activate
./run_scan.sh
```

This runs all 6 detection steps:
1. Image scanning (steghide + exiftool)
2. Entropy analysis
3. Audio/video scanning
4. Algorithm comparison
5. Bit-plane analysis
6. StegExpose analysis

### Run Individual Components

```bash
# Image scanning
python3 scripts/scan_images.py

# Audio/video scanning
python3 scripts/scan_audio_video.py

# Entropy analysis
python3 scripts/entropy_analysis.py

# Algorithm comparison
python3 scripts/analyze_algorithms.py

# Bit-plane analysis
python3 scripts/stegsolve_helper.py

# StegExpose only
./run_stegexpose.sh
```

### Data Extraction

```bash
source venv/bin/activate
./run_extract.sh
```

Extracts hidden data from stego files and saves to `extracted/` directory.

## Testing the Project

### Quick Test

```bash
# 1. Load dataset
./ingest-dataset.sh

# 2. Run full scan
source venv/bin/activate
./run_scan.sh

# 3. Check results
cat reports/detection_report.txt
```

### Verify Outputs

```bash
# Check detection report
cat reports/detection_report.txt

# Check bit-plane visualizations
ls -la reports/bitplanes/

# Check spectrogram outputs
ls -la reports/spectrograms/

# Check extracted data
ls -la extracted/images/
```

### Test Individual Components

```bash
# Test bit-plane extraction
python3 scripts/stegsolve_helper.py
ls reports/bitplanes/

# Test audio spectrogram analysis
python3 scripts/scan_audio_video.py
ls reports/spectrograms/

# Test StegExpose
./run_stegexpose.sh
tail -20 reports/detection_report.txt
```

### Expected Outputs

After running the full scan:

- **`reports/detection_report.txt`**: Complete forensic report with all analysis results
- **`reports/bitplanes/`**: Individual bit-plane images and LSB summary figures
- **`reports/spectrograms/`**: Spectrogram and waveform comparison plots
- **`extracted/images/`**: Extracted text files from stego images

## Troubleshooting

**Java not found:**
```bash
sudo apt install openjdk-17-jdk
```

**StegExpose JAR missing:**
```bash
mkdir -p tools
git clone https://github.com/b3dk7/StegExpose.git tools/StegExpose
```

**Librosa installation issues:**
```bash
sudo apt install ffmpeg
pip install librosa
```

**Virtual environment issues:**
```bash
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**Permission denied on scripts:**
```bash
chmod +x run_scan.sh run_extract.sh run_stegexpose.sh setup.sh
```

## Clean Reports

```bash
./clear_reports.sh
```

Or manually:
```bash
rm -rf reports/*
mkdir -p reports/bitplanes reports/spectrograms
```

## Quick Workflow

```bash
# 1. Install
./setup.sh

# 2. Load data
./ingest-dataset.sh

# 3. Run scan
source venv/bin/activate
./run_scan.sh

# 4. View results
cat reports/detection_report.txt

# 5. Extract (if needed)
./run_extract.sh
```
