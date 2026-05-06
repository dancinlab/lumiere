# F-CFA-MVP-5 measurement record

| Field | Value |
|---|---|
| **Spec § ref** | [`docs/camera/camera-filter-app.md §19.2`](../camera/camera-filter-app.md) |
| **Threshold** | energy per frame ≤ 75 mJ |
| **Trigger** | `> 75 mJ → retract battery-life claim (depletes 4000 mAh in <2 hr active)` |
| **Hardware** | iPhone 15 Pro · MetricKit |
| **Deadline** | 2026-09-30 |
| **Current status** | `not-yet-measured` |
| **GitHub issue** | [#5](https://github.com/need-singularity/lumiere/issues/5) |

## Pre-declared expected outcome

> Expected: does not fire (3 W camera-active × 16.67 ms = 50 mJ design budget with 50% margin to 75 mJ ceiling).
> — spec §19.2 raw 71 falsifiers (5)

## Measurements

| Date (UTC) | Build | n frames | mJ/frame (p50) | mJ/frame (p95) | Pass? | Run log |
|---|---|---|---|---|---|---|
| — | — | — | — | — | — | — |

## Verdict

(To be filled at deadline 2026-09-30.)

## Notes

- Measurement script: [`scripts/measure_energy.sh`](../../scripts/measure_energy.sh) — emits `device-only` status; iOS Simulator power model is not the iPhone 15 Pro A17 Pro power rail.
- Real measurement: opt-in MetricKit submission via `MXMetricManager` with a 10-min capture session.
