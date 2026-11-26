#!/bin/bash
# extract-firmware.sh
# Run ON THE TABLET (rooted) to extract all firmware needed for pmOS build
# Outputs a firmware.tar.gz that you can upload to GitHub Actions cache or release

set -euo pipefail

OUTPUT_DIR="${1:-/tmp/uke-firmware}"
OUTPUT_TAR="${2:-/tmp/uke-firmware.tar.gz}"

echo "=== Extracting firmware for Xiaomi Pad 7 (uke) ==="
mkdir -p "$OUTPUT_DIR"/qcom

# GPU firmware (Adreno 732 / gen71100)
echo "Extracting GPU firmware..."
for f in gen71100_gmu.bin gen71100_sqe.fw gen71100_zap.mbn; do
	for path in /vendor/firmware/"$f" /odm/firmware/"$f"; do
		if [ -f "$path" ]; then
			cp "$path" "$OUTPUT_DIR"/qcom/
			echo "  Found: $path"
			break
		fi
	done
done

# Touch firmware (NT36532)
echo "Extracting touch firmware..."
for f in novatek_nt36532_o82_fw_*.bin; do
	for path in /vendor/firmware/"$f" /odm/firmware/"$f"; do
		if [ -f "$path" ]; then
			cp "$path" "$OUTPUT_DIR"/qcom/
			echo "  Found: $path"
			break
		fi
	done
done

# Audio firmware (WCD938x, CS35L41)
echo "Extracting audio firmware..."
for f in wcd938x_*.bin cs35l41_*.bin; do
	for path in /vendor/firmware/"$f" /odm/firmware/"$f"; do
		if [ -f "$path" ]; then
			cp "$path" "$OUTPUT_DIR"/qcom/
			echo "  Found: $path"
			break
		fi
	done
done

# WiFi firmware (WCN6750 / ath11k)
echo "Extracting WiFi firmware..."
for f in ath11k/*.bin ath11k/*.bin.zst; do
	for path in /vendor/firmware/"$f" /odm/firmware/"$f"; do
		if [ -f "$path" ]; then
			mkdir -p "$OUTPUT_DIR"/qcom/ath11k
			cp "$path" "$OUTPUT_DIR"/qcom/ath11k/
			echo "  Found: $path"
			break
		fi
	done
done

# Bluetooth firmware
echo "Extracting Bluetooth firmware..."
for f in qca/*.hcd qca/*.bin; do
	for path in /vendor/firmware/"$f" /odm/firmware/"$f"; do
		if [ -f "$path" ]; then
			mkdir -p "$OUTPUT_DIR"/qcom/qca
			cp "$path" "$OUTPUT_DIR"/qcom/qca/
			echo "  Found: $path"
			break
		fi
	done
done

# Display panel firmware
echo "Extracting display panel firmware..."
for f in panel_*.bin; do
	for path in /vendor/firmware/"$f" /odm/firmware/"$f"; do
		if [ -f "$path" ]; then
			cp "$path" "$OUTPUT_DIR"/qcom/
			echo "  Found: $path"
			break
		fi
	done
done

# Sensor firmware
echo "Extracting sensor firmware..."
for f in sensor_*.bin; do
	for path in /vendor/firmware/"$f" /odm/firmware/"$f"; do
		if [ -f "$path" ]; then
			cp "$path" "$OUTPUT_DIR"/qcom/
			echo "  Found: $path"
			break
		fi
	done
done

# Create tarball
echo "=== Creating tarball: $OUTPUT_TAR ==="
tar -czf "$OUTPUT_TAR" -C "$OUTPUT_DIR" .
echo "Done! Firmware tarball: $OUTPUT_TAR"
echo "Size: $(du -h "$OUTPUT_TAR" | cut -f1)"

# Print summary
echo ""
echo "=== Firmware Summary ==="
find "$OUTPUT_DIR" -type f | sort