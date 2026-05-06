#!/usr/bin/env bash
#
# scripts/measure_latency.sh — F-CFA-MVP-1 / F-MC-MVP-1 latency proxy
#
# Runs the FrameTimingRecorderTests on the configured iOS Simulator
# destination and emits a single-line JSON summary on stdout. NOT a
# valid F-gate closure on its own — the gates demand iPhone 15 Pro
# reference hardware. Use this for dev-time confidence + CI smoke.
#
# Real F-gate closure path (post-device-acquisition):
#   1. Build Release scheme with timing instrumentation enabled
#   2. Install on iPhone 15 Pro
#   3. Run a 10-min capture session via TestFlight
#   4. MetricKit submission → docs/measurements/F-CFA-MVP-1.md row
#
# Usage:
#   scripts/measure_latency.sh [destination-id]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

DEST="${1:-}"
if [[ -z "$DEST" ]]; then
  DEST=$(xcrun simctl list devices available --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data['devices'].items():
    if 'iOS' not in runtime: continue
    for d in devices:
        if d.get('isAvailable') and 'iPhone' in d['name']:
            print(f\"platform=iOS Simulator,id={d['udid']}\")
            sys.exit(0)
")
fi

if [[ -z "$DEST" ]]; then
  echo '{"status":"error","reason":"no available iOS simulator destination"}' >&2
  exit 2
fi

if [[ ! -d Lumiere.xcodeproj ]]; then
  xcodegen generate >/dev/null
fi

xcodebuild \
  -project Lumiere.xcodeproj \
  -scheme Lumiere \
  -destination "$DEST" \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  -only-testing:LumiereTests/FrameTimingRecorderTests \
  test >/dev/null 2>&1

# The unit tests verify percentile math invariants on synthetic data,
# not real-device frame timing. A real measurement requires an XCUITest
# that drives the camera preview for a fixed window and reads back
# session.recorder.{p50Ms,p95Ms,sampleCount}.
echo '{"status":"smoke-pass","gate":"F-CFA-MVP-1|F-MC-MVP-1","scope":"simulator-percentile-invariants","valid_for_F_gate_closure":false,"reason":"spec hardware is iPhone 15 Pro; this is dev-time confidence only"}'
