# F-MC-MVP-5 measurement record

| Field | Value |
|---|---|
| **Spec § ref** | [`docs/studio/hexa-main-character.md §19.2`](../studio/hexa-main-character.md) |
| **Threshold** | aperture-shape lens-flare divergence ≤ 5° (100 synthetic test scenes, 6-blade aperture) |
| **Trigger** | `> 5° → retract physics fidelity claim` |
| **Hardware** | offline render of 100 synthetic 6-blade scenes |
| **Deadline** | 2026-09-30 |
| **Current status** | `not-yet-measured` (analytical model: 0° divergence) |
| **GitHub issue** | [#10](https://github.com/need-singularity/lumiere/issues/10) |

## Pre-declared expected outcome

> Expected: does not fire (geometric blade-edge model is exact; Born-Wolf 1999 §8 diffraction envelope deviations ≤ 1° in the paraxial regime).
> — spec §19.2 raw 71 falsifiers (5)

## Measurements

| Date (UTC) | Build | N scenes | Max divergence (°) | Pass? | Run log |
|---|---|---|---|---|---|
| 2026-05-06 | `dce8da0` | 0 (analytical only) | 0.0 | smoke-pass | `scripts/measure_aperture_divergence.swift` — geometric ideal model emits 0° |

## Verdict

Pending — analytical pre-check passes; empirical render through `LensFlareFrameProcessor` on 100 synthetic scenes is mk3.

## Notes

- Measurement script: [`scripts/measure_aperture_divergence.swift`](../../scripts/measure_aperture_divergence.swift) — pure offline, no device required.
- Empirical closure path: instrument `LensFlareFrameProcessor` with a render-trace mode that emits per-blade angles + run on 100 procedurally-generated test scenes.
