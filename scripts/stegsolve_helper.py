import os
import numpy as np
from PIL import Image
import matplotlib.pyplot as plt
from colorama import Fore, init

init(autoreset=True)

IMAGE_DIR = "datasets/images"
OUTPUT_DIR = "reports/bitplanes"
REPORT_FILE = "reports/detection_report.txt"

# Create output directory
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Process all images
processed_files = []

for filename in sorted(os.listdir(IMAGE_DIR)):
    if not filename.lower().endswith(('.jpg', '.jpeg', '.png')):
        continue
    
    image_path = os.path.join(IMAGE_DIR, filename)
    print(Fore.YELLOW + f"  Processing {filename}...")
    
    # Open image and convert to RGB
    img = Image.open(image_path).convert('RGB')
    img_array = np.array(img)
    
    # Extract all bit planes for each channel
    channels = ['R', 'G', 'B']
    for channel_idx, channel_name in enumerate(channels):
        for bit in range(8):
            # Extract bit plane: ((pixel >> bit) & 1) * 255
            plane = ((img_array[:, :, channel_idx] >> bit) & 1) * 255
            plane_img = Image.fromarray(plane.astype(np.uint8), mode='L')
            
            # Save individual bit plane
            output_name = f"{filename}_{channel_name}_bit{bit}.png"
            output_path = os.path.join(OUTPUT_DIR, output_name)
            plane_img.save(output_path)
    
    # Generate LSB summary figure (bit 0 only for all 3 channels)
    fig, axes = plt.subplots(1, 3, figsize=(12, 4))
    for channel_idx, channel_name in enumerate(channels):
        lsb_plane = ((img_array[:, :, channel_idx] >> 0) & 1) * 255
        axes[channel_idx].imshow(lsb_plane, cmap='gray')
        axes[channel_idx].set_title(f"{channel_name} LSB")
        axes[channel_idx].axis('off')
    
    plt.tight_layout()
    lsb_summary_path = os.path.join(OUTPUT_DIR, f"{filename}_lsb_summary.png")
    plt.savefig(lsb_summary_path, dpi=100)
    plt.close()
    
    processed_files.append((filename, lsb_summary_path))

# Append to detection report
with open(REPORT_FILE, "a") as report:
    report.write("\n")
    report.write("=" * 60 + "\n")
    report.write("STEGSOLVE BIT-PLANE ANALYSIS (Headless)\n")
    report.write("=" * 60 + "\n")
    report.write("\n")
    report.write("Note: StegSolve GUI replaced by headless Python bit-plane extraction.\n")
    report.write(f"Output images saved to: {OUTPUT_DIR}/\n")
    report.write("\n")
    report.write("FILES PROCESSED:\n")
    for filename, lsb_path in processed_files:
        report.write(f"  {filename}  -> LSB summary: {lsb_path}\n")
    report.write("\n")
    report.write("INTERPRETATION GUIDE:\n")
    report.write("  - A uniform/noisy LSB plane in a stego image indicates hidden data\n")
    report.write("  - Clean images show structured LSB patterns following natural image gradients\n")
    report.write("  - Compare clean_N.jpg vs stego_N.jpg LSB summaries for each pair\n")
    report.write("\n")

print(Fore.GREEN + "[OK] Bit-plane analysis complete. Results saved to reports/bitplanes/")
