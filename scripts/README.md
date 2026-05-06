# scripts/

Measurement + CI helpers. None of these substitute for the iPhone 15 Pro reference measurements demanded by spec §19.2 — they provide dev-time confidence and CI smoke validation. Each script emits a JSON line with `valid_for_F_gate_closure` set to `false` until the device + dataset + panel preconditions are met.

## Shipped (mk2-C)

| Script | F-gate | Deadline | Status |
|---|---|---|---|
| [`measure_latency.sh`](measure_latency.sh) | F-CFA-MVP-1 / F-MC-MVP-1 | 2026-08-30 | simulator percentile invariants pass |
| [`measure_npu.sh`](measure_npu.sh) | F-CFA-MVP-2 | 2026-08-30 | device-only (xctrace Metal System Trace) |
| [`measure_jpeg_size.sh`](measure_jpeg_size.sh) | F-CFA-MVP-3 | 2026-08-30 | sips encoder fixture set; needs `Tests/fixtures/jpeg-12mp/` seed |
| [`measure_studio_pipeline.sh`](measure_studio_pipeline.sh) | F-MC-MVP-1 | 2026-08-30 | runs Cinematic + Anamorphic + Timing test suites |
| [`measure_energy.sh`](measure_energy.sh) | F-CFA-MVP-5 | 2026-09-30 | device-only (MetricKit) |
| [`measure_genre_accuracy.swift`](measure_genre_accuracy.swift) | F-MC-MVP-3 | 2026-08-30 | weights + dataset required (CLIP-B/16 + 1000 clips) |
| [`measure_clap_mos.swift`](measure_clap_mos.swift) | F-MC-MVP-4 | 2026-09-30 | weights + panel required (CLAP + N=20) |
| [`measure_aperture_divergence.swift`](measure_aperture_divergence.swift) | F-MC-MVP-5 | 2026-09-30 | analytical 0° smoke-pass; empirical render is mk3 |

## Conversion

| Script | Purpose |
|---|---|
| [`convert_models.hexa`](convert_models.hexa) | torchvision / CLIP / SAM → Core ML INT8 `.mlpackage` (resnet50 implemented; CLIP + SAM stub-NotImplemented). hexa-only entry point per project policy; coremltools + torch are an irreducible Python ML dependency invoked via embedded `python3 -` heredoc. |

## Pending (post-mk2)

User-panel gates demand TestFlight cohort recruitment, not a script:
- F-CFA-MVP-4 (camera MOS, N=30) — release.cond.4 dependency
- F-MC-MVP-2  (studio A/B vs Instagram+VSCO+Rush, N=30) — release.cond.4 + studio.blk.2
- F-MC-MVP-4  (CLAP MOS, N=20) — handled by panel side of `measure_clap_mos.swift`

Forge / Mirror / Atelier F-gates (F-FA-MVP-1..5 / F-PSELF-MVP-1..5 / F-VSCO-MVP-1..5) become measurable once their `.roadmap.<domain>` cond.2 runtime lands (mk3+).

## Conventions

- Every script outputs a single-line JSON object on stdout.
- Required fields: `status`, `gate`, `valid_for_F_gate_closure` (boolean), `reason` (string).
- Optional fields: `n`, percentile data (`p50_*`, `p95_*`), `threshold_*`, `expected`.
- Bash scripts use `set -euo pipefail`; Swift scripts run via `#!/usr/bin/env swift` shebang.
- All shipped scripts are `chmod +x` executable.
- Naming: `measure_<gate-or-metric>.{sh,swift}` — sh for environmental/system probes, swift for offline computational checks.
