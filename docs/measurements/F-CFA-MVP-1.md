# F-CFA-MVP-1 measurement record

| Field | Value |
|---|---|
| **Spec § ref** | [`docs/camera/camera-filter-app.md §19.2`](../camera/camera-filter-app.md) |
| **Threshold** | latency p95 ≤ 25 ms (capture-to-preview at 60 fps) |
| **Trigger** | `p95 > 25 ms → retract real-time claim` |
| **Hardware** | iPhone 15 Pro |
| **Deadline** | 2026-08-30 |
| **Current status** | `not-yet-measured` |
| **GitHub issue** | [#1](https://github.com/need-singularity/lumiere/issues/1) |

## Pre-declared expected outcome

> Expected: does not fire (Roofline + 16.67 ms budget head-room).
> — spec §19.2 raw 71 falsifiers (5)

## Measurements

| Date (UTC) | Build | p50 (ms) | p95 (ms) | n | Pass? | Run log |
|---|---|---|---|---|---|---|
| — | — | — | — | — | — | — |

## Verdict

(To be filled at deadline 2026-08-30 or when sufficient evidence accumulates.)

- **Final status**: TBD
- **Closing build**: TBD
- **Issue resolution**: TBD

## Notes

- The live `FrameTimingRecorder` HUD turns red above 25 ms p95 — manual smoke check before any device run.
- Measurement script: `scripts/measure_latency.sh` (TBD — Stage D follow-up).
- Simulator measurements are NOT valid for this gate (spec hardware = iPhone 15 Pro).
