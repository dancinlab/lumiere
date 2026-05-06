#!/usr/bin/env bash
#
# scripts/measure_jpeg_size.sh — F-CFA-MVP-3 JPEG qf85 size proxy
#
# Encodes a fixture set of 12 MP RGB images at JPEG qfactor 85 via
# `sips`, computes p50 + p95 file size in MB. Threshold: p95 ≤ 4 MB
# at 12 MP per spec §19.2.
#
# Honest scope: macOS `sips` is NOT the iPhone 15 Pro on-device JPEG
# encoder (different quantization tables + chroma subsampling). Use
# this for dev-time confidence; real F-gate closure needs an
# XCUITest that captures real frames through AVCapturePhotoOutput.
#
# Usage:
#   scripts/measure_jpeg_size.sh [fixtures-dir]
#
# Default fixtures-dir: Tests/fixtures/jpeg-12mp/ (not yet seeded)

set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIXTURES_DIR="${1:-$REPO_ROOT/Tests/fixtures/jpeg-12mp}"

if [[ ! -d "$FIXTURES_DIR" ]]; then
  printf '{"status":"missing-fixtures","gate":"F-CFA-MVP-3","fixtures_dir":"%s","valid_for_F_gate_closure":false,"reason":"seed Tests/fixtures/jpeg-12mp/ with 12 MP RGB sources before running"}\n' "$FIXTURES_DIR"
  exit 0
fi

TMP="$(mktemp -d)"
trap "rm -rf $TMP" EXIT

SIZES=()
for f in "$FIXTURES_DIR"/*; do
  [[ -f "$f" ]] || continue
  out="$TMP/$(basename "$f").jpg"
  if sips -s format jpeg -s formatOptions 85 "$f" --out "$out" >/dev/null 2>&1; then
    size_mb=$(du -m "$out" | awk '{print $1}')
    SIZES+=("$size_mb")
  fi
done

count=${#SIZES[@]}
if [[ $count -eq 0 ]]; then
  echo '{"status":"no-fixtures-encoded","gate":"F-CFA-MVP-3","valid_for_F_gate_closure":false}'
  exit 0
fi

SORTED=$(printf '%s\n' "${SIZES[@]}" | sort -n)
p50_idx=$(( count / 2 ))
p95_idx=$(( (count - 1) * 95 / 100 ))
p50=$(printf '%s' "$SORTED" | sed -n "$((p50_idx+1))p")
p95=$(printf '%s' "$SORTED" | sed -n "$((p95_idx+1))p")

printf '{"status":"smoke-pass","gate":"F-CFA-MVP-3","scope":"sips-encoder-fixture-set","valid_for_F_gate_closure":false,"reason":"macOS sips is not the iPhone 15 Pro on-device JPEG encoder","n":%d,"p50_mb":%s,"p95_mb":%s,"threshold_mb":4}\n' "$count" "$p50" "$p95"
