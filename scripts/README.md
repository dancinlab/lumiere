# scripts/

Measurement + CI helpers. None of these substitute for the iPhone 15 Pro reference measurements demanded by spec §19.2 — they provide dev-time confidence and CI smoke validation.

| Script | Stage | F-gate proxy | Valid for closure? |
|---|---|---|---|
| `measure_latency.sh` | D | F-CFA-MVP-1 / F-MC-MVP-1 | no (simulator) |

## Roadmap

The remaining 8 measurement scripts are pending. They follow the same pattern: dev-time CI proxy on simulator, then a device-targeted XCUITest harness that emits a JSON metric the corresponding `docs/measurements/F-*.md` row consumes.

| Pending script | Gate | Tool path |
|---|---|---|
| `measure_npu.sh` | F-CFA-MVP-2 | `xctrace record --template "Metal System Trace"` (NPU sampling) |
| `measure_jpeg_size.sh` | F-CFA-MVP-3 | encode 12 MP fixture set at qf 85 |
| `measure_energy.sh` | F-CFA-MVP-5 | `MetricKit` daily diagnostic |
| `measure_studio_pipeline.sh` | F-MC-MVP-1 | XCUITest launching all 9 effects |
| `measure_genre_accuracy.swift` | F-MC-MVP-3 | offline run on 1000-clip labeled set |
| `measure_clap_mos.swift` | F-MC-MVP-4 | offline CLAP cosine + N=20 panel pipeline |
| `measure_aperture_divergence.swift` | F-MC-MVP-5 | offline render of 100 synthetic 6-blade scenes |

User-panel gates (F-CFA-MVP-4 / F-MC-MVP-2) need TestFlight cohort recruitment, not a script.
