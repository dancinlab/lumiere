# F-MC-MVP-4 measurement record

| Field | Value |
|---|---|
| **Spec § ref** | [`docs/studio/hexa-main-character.md §19.2`](../studio/hexa-main-character.md) |
| **Threshold** | scene-music CLAP MOS ≥ 4.0/5 (N=20 panel) |
| **Trigger** | `< 4.0 → retract music suggestion claim` |
| **Hardware** | N=20 panel · CLAP scene-music matching |
| **Deadline** | 2026-09-30 |
| **Current status** | `not-yet-measured` |
| **GitHub issue** | [#9](https://github.com/need-singularity/lumiere/issues/9) |

## Pre-declared expected outcome

> Expected: does not fire (CLAP cos-sim threshold 0.5 is ~11.3 sigma above 1/sqrt(512) noise per Block F; Wu et al. ICASSP 2023 §4 reports human-rated retrieval P@1 ≥ 0.7 at this threshold).
> — spec §19.2 raw 71 falsifiers (5)

## Measurements

| Date (UTC) | Build | N | Mean MOS | Pass? | Run log |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

## Verdict

(To be filled at deadline 2026-09-30.)

## Notes

- Measurement script: [`scripts/measure_clap_mos.swift`](../../scripts/measure_clap_mos.swift) — emits `weights-and-panel-required` status.
- Depends on CLAP weights addition to `scripts/convert_models.py` (mk3) + N=20 panel recruitment.
