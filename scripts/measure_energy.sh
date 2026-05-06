#!/usr/bin/env bash
#
# scripts/measure_energy.sh — F-CFA-MVP-5 energy proxy
#
# Real F-gate closure path: opt-in MetricKit submission
# (MXAppLaunchMetric + MXCPUMetric + MXDisplayMetric) collected over
# a 10-min capture session on iPhone 15 Pro, derived
# energy = avg_power_W * frame_time_s.
#
# Threshold: ≤ 75 mJ per frame per spec §19.2 (50 mJ design budget +
# 50% safety margin).
#
# Simulator cannot measure real energy — power model in simulator is
# not the iPhone 15 Pro A17 Pro power rail.
set -euo pipefail

cat <<'EOF'
{"status":"device-only","gate":"F-CFA-MVP-5","scope":"MetricKit-energy","valid_for_F_gate_closure":false,"reason":"energy measurement requires on-device MetricKit submission via MXMetricManager; iOS Simulator power model is not iPhone 15 Pro A17 Pro","threshold_mj_per_frame":75,"expected":"does-not-fire (3 W * 16.67 ms = 50 mJ design budget)"}
EOF
