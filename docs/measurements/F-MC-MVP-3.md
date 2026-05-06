# F-MC-MVP-3 measurement record

| Field | Value |
|---|---|
| **Spec § ref** | [`docs/studio/hexa-main-character.md §19.2`](../studio/hexa-main-character.md) |
| **Threshold** | genre auto-detection accuracy ≥ 70% (1000-clip labeled set) |
| **Trigger** | `< 70% → retract genre classifier` |
| **Hardware** | offline + iPhone 15 Pro inference (CLIP-B/16 + 6-class SVM) |
| **Deadline** | 2026-08-30 |
| **Current status** | `not-yet-measured` |
| **GitHub issue** | [#8](https://github.com/need-singularity/lumiere/issues/8) |

## Pre-declared expected outcome

> Expected: does not fire (CLIP-B/16 latent + 6-class SVM head reaches 77-82% on similar mood-classification benchmarks per Radford et al. 2021 §3 zero-shot transfer numbers).
> — spec §19.2 raw 71 falsifiers (5)

## Measurements

| Date (UTC) | Build | N clips | Top-1 Acc % | Pass? | Run log |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

## Verdict

(To be filled at deadline 2026-08-30.)

## Notes

- Measurement script: [`scripts/measure_genre_accuracy.swift`](../../scripts/measure_genre_accuracy.swift) — emits `weights-and-dataset-required` status.
- Depends on camera.cond.2 (CLIP-Image INT8 weights via `scripts/convert_models.py clip_image`) + 1000-clip labeled curation.
