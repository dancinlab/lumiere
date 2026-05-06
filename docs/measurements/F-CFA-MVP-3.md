# F-CFA-MVP-3 measurement record

| Field | Value |
|---|---|
| **Spec § ref** | [`docs/camera/camera-filter-app.md §19.2`](../camera/camera-filter-app.md) |
| **Threshold** | JPEG @ qfactor 85 size ≤ 4 MB at 12 MP |
| **Trigger** | `p95 > 4 MB → retract compression target` |
| **Hardware** | iPhone 15 Pro · 12 MP capture |
| **Deadline** | 2026-08-30 |
| **Current status** | `not-yet-measured` |
| **GitHub issue** | [#3](https://github.com/need-singularity/lumiere/issues/3) |

## Pre-declared expected outcome

> Expected: does not fire (Wallace 1991 quantization tables + 12 MP at qf 85 typically 3–4 MB for natural scenes).
> — spec §19.2 raw 71 falsifiers (5)

## Measurements

| Date (UTC) | Build | n | p50 (MB) | p95 (MB) | Pass? | Run log |
|---|---|---|---|---|---|---|
| — | — | — | — | — | — | — |

## Verdict

(To be filled at deadline 2026-08-30.)

## Notes

- Measurement script: [`scripts/measure_jpeg_size.sh`](../../scripts/measure_jpeg_size.sh) — uses macOS `sips` against `Tests/fixtures/jpeg-12mp/` (fixture set TBD). `sips` is NOT the iPhone 15 Pro on-device JPEG encoder; real measurement needs `AVCapturePhotoOutput` round-trip on device.
