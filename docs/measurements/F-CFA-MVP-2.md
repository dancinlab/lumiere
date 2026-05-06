# F-CFA-MVP-2 measurement record

| Field | Value |
|---|---|
| **Spec § ref** | [`docs/camera/camera-filter-app.md §19.2`](../camera/camera-filter-app.md) |
| **Threshold** | NPU utilization ≤ 50% sustained (filter-active) |
| **Trigger** | `> 50% → retract headroom design margin` |
| **Hardware** | iPhone 15 Pro |
| **Deadline** | 2026-08-30 |
| **Current status** | `not-yet-measured` |
| **GitHub issue** | [#2](https://github.com/need-singularity/lumiere/issues/2) |

## Pre-declared expected outcome

> Expected: does not fire (17.5 / 35 = 50% by construction; sustained < 50% is the empirical question).
> — spec §19.2 raw 71 falsifiers (5)

## Measurements

| Date (UTC) | Build | NPU % (p50) | NPU % (p95) | Pass? | Run log |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

## Verdict

(To be filled at deadline 2026-08-30.)

## Notes

- Measurement script: [`scripts/measure_npu.sh`](../../scripts/measure_npu.sh) — currently emits `device-only` status. Real NPU counters require `xctrace record --template "Metal System Trace"` on a tethered iPhone 15 Pro.
- 17.5 TOPS = 50% headroom of A17 Pro 35 TOPS — design constraint per spec §10 ARCHITECTURE.
