# Lumière measurement records

This directory holds the empirical measurement records that close (or escalate) each pre-declared F-gate falsifier from the spec §19.2 of `docs/camera/camera-filter-app.md` and `docs/studio/hexa-main-character.md`.

Each gate has a dedicated record file: `F-CFA-MVP-{1..5}.md` (camera) and `F-MC-MVP-{1..5}.md` (studio). They start as `not-yet-measured` and update with timestamped runs against the spec-mandated **iPhone 15 Pro** reference hardware until either:

- All measurements stay below threshold by the deadline → gate closes `does-not-fire`, the corresponding GitHub issue is closed, the spec claim stands.
- A measurement crosses threshold → gate `fires`, the design claim is retracted, the issue is escalated, and a mk2 redesign cycle is opened.

Roadmap reference: [`.roadmap.camera`](../../.roadmap.camera) cond.3 + [`.roadmap.studio`](../../.roadmap.studio) cond.4.

## Measurement methodology

| Gate | Measure | Tool | Hardware |
|---|---|---|---|
| F-CFA-MVP-1 | latency p95 (ms) at 60 fps preview | `FrameTimingRecorder` + `scripts/measure_latency.sh` | iPhone 15 Pro |
| F-CFA-MVP-2 | NPU utilization (%) sustained | `xctrace` Instruments NPU sampling | iPhone 15 Pro |
| F-CFA-MVP-3 | JPEG @ qf85 size (MB) at 12 MP | `scripts/measure_jpeg_size.sh` | iPhone 15 Pro |
| F-CFA-MVP-4 | perceptual quality MOS (1-5) | N=30 user blind panel | TestFlight cohort |
| F-CFA-MVP-5 | energy per frame (mJ) | `MetricKit` energy diagnostic | iPhone 15 Pro |
| F-MC-MVP-1 | studio pipeline p95 (ms), 9 effects active | same as CFA-1 | iPhone 15 Pro |
| F-MC-MVP-2 | A/B preference vs commodity stack (%) | N=30 blind A/B (HEXA-MC vs Instagram + VSCO + Premiere Rush) | TestFlight cohort |
| F-MC-MVP-3 | genre auto-detection accuracy (%) | 1000-clip labeled test set | offline + iPhone 15 Pro inference |
| F-MC-MVP-4 | scene-music CLAP MOS (1-5) | N=20 panel | TestFlight cohort |
| F-MC-MVP-5 | aperture-shape divergence (deg) | 100 synthetic 6-blade test scenes | offline render |

## Record file structure

See [`_template.md`](_template.md). Each record carries:

1. **Header** — gate ID, spec section, threshold, deadline, current status.
2. **Measurements** — append-only table, one row per device run with date / build hash / metric / pass-fail.
3. **Verdict** — final `does-not-fire` / `fires` decision once measurement window closes (deadline passes or sufficient evidence accumulates).

Pre-declared deadlines (spec §19.2):
- 2026-08-30 — F-CFA-MVP-1, F-CFA-MVP-2, F-CFA-MVP-3, F-MC-MVP-1, F-MC-MVP-2, F-MC-MVP-3
- 2026-09-30 — F-CFA-MVP-4, F-CFA-MVP-5, F-MC-MVP-4, F-MC-MVP-5

## Cross-references

- Spec source: [`docs/camera/camera-filter-app.md` §19.2](../camera/camera-filter-app.md) · [`docs/studio/hexa-main-character.md` §19.2](../studio/hexa-main-character.md)
- GitHub issues: [#1–5 (camera)](https://github.com/need-singularity/lumiere/issues?q=label%3Acamera) · [#6–10 (studio)](https://github.com/need-singularity/lumiere/issues?q=label%3Astudio)
- Milestones: [F-MVP 2026-08-30](https://github.com/need-singularity/lumiere/milestones) · [F-MVP 2026-09-30](https://github.com/need-singularity/lumiere/milestones)
