#!/bin/bash
# run_stegexpose.sh

STEGEXPOSE_JAR="tools/StegExpose/StegExpose.jar"
IMAGE_DIR="datasets/images"
REPORT_FILE="reports/detection_report.txt"
THRESHOLD="0.2"
CSV_OUTPUT="/tmp/stegexpose_results.csv"

echo "=========================================="
echo " StegExpose Analysis"
echo "=========================================="

# Check Java
if ! command -v java &> /dev/null; then
    echo "[-] Java is not installed. Install openjdk-17-jdk and retry."
    {
    echo ""
    echo "=============================="
    echo "STEGEXPOSE RESULTS"
    echo "Threshold: $THRESHOLD"
    echo "Images analyzed: $(ls $IMAGE_DIR/*.jpg 2>/dev/null | wc -l)"
    echo "=============================="
    echo "ERROR: Java not installed. Install openjdk-17-jdk to run StegExpose."
    echo ""
    } >> "$REPORT_FILE"
    exit 1
fi

# Check StegExpose JAR — clone if missing
if [ ! -f "$STEGEXPOSE_JAR" ]; then
    echo "[-] StegExpose JAR not found. Cloning..."
    mkdir -p tools
    git clone https://github.com/b3dk7/StegExpose.git tools/StegExpose 2>&1
fi

if [ ! -f "$STEGEXPOSE_JAR" ]; then
    echo "[-] StegExpose.jar not found after clone attempt. Skipping."
    {
    echo ""
    echo "=============================="
    echo "STEGEXPOSE RESULTS"
    echo "Threshold: $THRESHOLD"
    echo "=============================="
    echo "ERROR: StegExpose.jar not found at $STEGEXPOSE_JAR"
    echo ""
    } >> "$REPORT_FILE"
    exit 1
fi

# Convert to absolute path — StegExpose requires this
ABS_IMAGE_DIR=$(realpath "$IMAGE_DIR")
IMAGE_COUNT=$(ls "$ABS_IMAGE_DIR"/*.jpg 2>/dev/null | wc -l)

echo "[+] Running StegExpose on $ABS_IMAGE_DIR"
echo "    Threshold : $THRESHOLD"
echo "    Images    : $IMAGE_COUNT"

# --- Attempt 1: output to CSV file (most reliable across versions) ---
rm -f "$CSV_OUTPUT"
java -jar "$STEGEXPOSE_JAR" "$ABS_IMAGE_DIR" "$THRESHOLD" "$CSV_OUTPUT" > /tmp/se_stdout.txt 2>&1
EXIT1=$?

SE_OUTPUT=""

if [ -f "$CSV_OUTPUT" ] && [ -s "$CSV_OUTPUT" ]; then
    echo "[+] StegExpose CSV output captured."
    SE_OUTPUT=$(cat "$CSV_OUTPUT")
fi

# --- Attempt 2: stdout only (fallback) ---
if [ -z "$SE_OUTPUT" ]; then
    SE_OUTPUT=$(java -jar "$STEGEXPOSE_JAR" "$ABS_IMAGE_DIR" "$THRESHOLD" 2>&1)
fi

# --- Attempt 3: try with just the directory (no threshold arg) ---
if [ -z "$SE_OUTPUT" ]; then
    SE_OUTPUT=$(java -jar "$STEGEXPOSE_JAR" "$ABS_IMAGE_DIR" 2>&1)
fi

echo ""
if [ -z "$SE_OUTPUT" ]; then
    echo "[-] StegExpose produced no output on any invocation style."
    SE_OUTPUT="StegExpose produced no output. The JAR may need recompiling or a different Java version."
else
    echo "$SE_OUTPUT"
fi
echo ""

# Append to detection report
{
echo ""
echo "=============================="
echo "STEGEXPOSE RESULTS"
echo "Threshold: $THRESHOLD"
echo "Images analyzed: $IMAGE_COUNT"
echo "=============================="
echo "$SE_OUTPUT"
echo ""
} >> "$REPORT_FILE"

echo "[OK] StegExpose results appended to $REPORT_FILE"
