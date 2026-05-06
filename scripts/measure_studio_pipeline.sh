#!/usr/bin/env bash
#
# scripts/measure_studio_pipeline.sh — F-MC-MVP-1 9-effect pipeline proxy
#
# Runs FrameTimingRecorderTests + CinematicEffectProcessorTests +
# AnamorphicFrameProcessorTests via xcodebuild on the available
# simulator. Aggregates pass/fail status; the percentile invariants
# in FrameTimingRecorderTests stand in as a synthetic latency proxy.
#
# Real F-gate closure: XCUITest that drives StudioView through all
# 9 effects active simultaneously for 10 min on iPhone 15 Pro,
# emitting per-frame timing back via the FrameTimingRecorder HUD.
# Threshold p95 ≤ 25 ms per spec §19.2.
set -euo pipefail
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

if [[ ! -d Lumiere.xcodeproj ]]; then
  xcodegen generate >/dev/null
fi

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

if [[ -z "$DEST" ]]; then
  echo '{"status":"error","gate":"F-MC-MVP-1","reason":"no available iOS simulator destination"}' >&2
  exit 2
fi

xcodebuild -project Lumiere.xcodeproj -scheme Lumiere \
  -destination "$DEST" -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  -only-testing:LumiereTests/CinematicEffectProcessorTests \
  -only-testing:LumiereTests/AnamorphicFrameProcessorTests \
  -only-testing:LumiereTests/FrameTimingRecorderTests \
  test >/dev/null 2>&1 && STATUS="smoke-pass" || STATUS="smoke-fail"

cat <<EOF
{"status":"$STATUS","gate":"F-MC-MVP-1","scope":"simulator-pipeline-tests-{cinematic,anamorphic,timing}","valid_for_F_gate_closure":false,"reason":"true 9-effect pipeline p95 requires iPhone 15 Pro + 10-min cinematic capture XCUITest","threshold_p95_ms":25}
EOF
