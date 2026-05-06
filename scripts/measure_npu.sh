#!/usr/bin/env bash
#
# scripts/measure_npu.sh — F-CFA-MVP-2 NPU utilization proxy
#
# Real F-gate closure path: `xctrace record --template
# "Metal System Trace"` attached to a 10-min capture session on an
# iPhone 15 Pro tethered via USB-C, then post-process the .trace
# bundle to extract NPU time-share percentile (target: sustained
# ≤ 50% per spec §19.2).
#
# This script can only document the requirement on simulator —
# Apple's NPU counters are not exposed on iOS Simulator hardware.
set -euo pipefail

cat <<'EOF'
{"status":"device-only","gate":"F-CFA-MVP-2","scope":"xctrace-NPU-time-share","valid_for_F_gate_closure":false,"reason":"NPU counters are not exposed on iOS Simulator; requires xctrace record --template 'Metal System Trace' on iPhone 15 Pro tethered via USB-C with a 10-min capture session","threshold_pct":50,"expected":"does-not-fire (17.5/35 = 50% by construction)"}
EOF
