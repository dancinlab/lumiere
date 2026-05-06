# F-CFA-MVP-4 measurement record

| Field | Value |
|---|---|
| **Spec § ref** | [`docs/camera/camera-filter-app.md §19.2`](../camera/camera-filter-app.md) |
| **Threshold** | perceptual quality MOS ≥ 4.0/5 (N=30 panel) |
| **Trigger** | `< 4.0 → retract quality target` |
| **Hardware** | iPhone 15 Pro · N=30 user MOS panel |
| **Deadline** | 2026-09-30 |
| **Current status** | `not-yet-measured` |
| **GitHub issue** | [#4](https://github.com/need-singularity/lumiere/issues/4) |

## Pre-declared expected outcome

> Expected: does not fire (CLIP+SAM+ResNet-50 INT8 stack matches FP16 reference within 0.1 MOS per Jacob 2018).
> — spec §19.2 raw 71 falsifiers (5)

## Measurements

| Date (UTC) | Build | N | Mean MOS | Pass? | Run log |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

## Verdict

(To be filled at deadline 2026-09-30.)

## Notes

- Requires camera.cond.2 (real Core ML stack) + TestFlight 100-user beta cohort.
- Panel methodology per Jacob et al. CVPR 2018 §6.
