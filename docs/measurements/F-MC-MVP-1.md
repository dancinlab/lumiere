# F-MC-MVP-1 measurement record

| Field | Value |
|---|---|
| **Spec § ref** | [`docs/studio/hexa-main-character.md §19.2`](../studio/hexa-main-character.md) |
| **Threshold** | studio pipeline p95 ≤ 25 ms (60 fps with all 9 effects active) |
| **Trigger** | `p95 > 25 ms → retract real-time claim` |
| **Hardware** | iPhone 15 Pro |
| **Deadline** | 2026-08-30 |
| **Current status** | `not-yet-measured` |
| **GitHub issue** | [#6](https://github.com/need-singularity/lumiere/issues/6) |

## Pre-declared expected outcome

> Expected: does not fire (16.67 ms budget × 12-stage decomposition with 0.17 ms slack provides margin; Lucas-Kanade GOps fits within 1.8 ms NPU stage per Block C).
> — spec §19.2 raw 71 falsifiers (5)

## Measurements

| Date (UTC) | Build | Active effects | p50 (ms) | p95 (ms) | n | Pass? | Run log |
|---|---|---|---|---|---|---|---|
| — | — | anamorphic only (Stage B mk1) | — | — | — | — | — |

## Verdict

(To be filled at deadline 2026-08-30 or when sufficient evidence accumulates.)

- **Final status**: TBD
- **Closing build**: TBD
- **Issue resolution**: TBD

## Notes

- Stage B (commit `d9891e5`) implements 1 of 9 effects (anamorphic 2.39:1).
- Full 9-effect measurement requires Stage C-equivalent for all effects (mk2 cycle).
- Same `FrameTimingRecorder` infrastructure as F-CFA-MVP-1; the recorder lives in the shared `CameraSession` and is reused by `StudioCameraView`.
- Per spec, the "all 9 effects active" condition is the binding case.
