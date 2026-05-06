# Lumière ✨

> 빛으로 찍고, 빛으로 연출하다 — *Capture in light, direct in light*

**Lumière** is a physical-limit iOS app that absorbs the entire `apps` axis of [n6-architecture](https://github.com/need-singularity/n6-architecture) — 5 verb-distinct surfaces unified under the 16.67 ms real-time budget (60 fps Nyquist) and the Airy diffraction limit.

---

## Two tabs · five surfaces

The 5 verb-distinct sister specs are absorbed into 2 iOS tabs by capture-vs-post-capture concern. Verb-distinction is preserved as sub-mode within each tab.

| Tab | Sub-mode | Verb | Spec | Status |
|---|---|---|---|---|
| 📸 **Camera** | Filters | APPLIES | `camera-filter-app` | mk1 live · timing HUD · 16.67 ms p95 |
| 📸 **Camera** | Mirror | GENERATES | `hexa-parallel-self` | mk1 capture-shell + 8-grid placeholder |
| 🎬 **Studio** | Direct | DIRECTS | `hexa-main-character` | mk1 anamorphic 2.39:1 + 8 mk2 effects |
| 🎬 **Studio** | Edit (Atelier) | EDITS · LIBRARY · DISCOVER | `hexa-vsco` | mk1 placeholder · full surface mk2 |
| 🎬 **Studio** | Author (Forge) | AUTHORS | `hexa-filter-algebra` | mk1 placeholder + 9 primitive op catalog · runtime mk2 |

All five share the 16.67 ms hard real-time budget and 50 mJ/frame energy ceiling. The Camera tab routes live-capture surfaces (APPLIES + GENERATES); the Studio tab routes post-capture creative surfaces (DIRECTS + EDITS + AUTHORS).

## Physical-limit anchors

- **Real-time** — 1000/60 fps = 16.67 ms (Nyquist visual perception)
- **Compute** — 17.5 TOPS (50% of Apple A17 Pro headroom)
- **Memory** — Williams-Waterman-Patterson 2009 Roofline (50 FLOPs/byte × 51.2 GB/s DRAM)
- **Optics** — Airy 1835 diffraction limit · θ_min = 1.22 λ/D
- **Sensor** — Poisson photon shot noise · σ_shot = √N_photons
- **Codec** — Wallace 1991 JPEG · Rec.2020 wide gamut
- **Energy** — 50 mJ/frame (3 W × 16.67 ms)

## Camera mode — 9 reference effects

Anamorphic 2.39:1 · teal-orange grading · Lucas-Kanade 1981 optical-flow slow-mo · depth-bokeh · hexagonal-aperture Snell+Fresnel lens flare · Cox 1955 Kodak Vision3 5219 grain · decisive-moment freeze · Wu 2023 CLAP scene-music · Reinhard-Devlin 2002 tone

## Status

`mk1` — pre-MVP scaffold. Each of the 5 modes carries a 5-tuple of pre-declared 90-day falsifier gates (25 total) against iPhone 15 Pro reference, deadlines **2026-08-30 / 2026-09-30**:

| Mode | F-gate prefix | GitHub issues |
|---|---|---|
| Camera | F-CFA-MVP-1..5 | [#1–5](https://github.com/need-singularity/lumiere/issues?q=label%3Acamera) |
| Studio | F-MC-MVP-1..5 | [#6–10](https://github.com/need-singularity/lumiere/issues?q=label%3Astudio) |
| Forge | F-FA-MVP-1..5 | [#11–15](https://github.com/need-singularity/lumiere/issues?q=label%3Aforge) |
| Mirror | F-PSELF-MVP-1..5 | [#16–20](https://github.com/need-singularity/lumiere/issues?q=label%3Amirror) |
| Atelier | F-VSCO-MVP-1..5 | [#21–25](https://github.com/need-singularity/lumiere/issues?q=label%3Aatelier) |

mk1 ships UI for Camera + Studio (anamorphic 2.39:1 first effect); Forge / Mirror / Atelier mk1 specs are absorbed into `docs/` with [`.roadmap.<domain>`](.roadmap.camera) tracking. mk2 implements full surfaces.

## Specs

- [docs/camera/camera-filter-app.md](docs/camera/camera-filter-app.md) — 📸 Camera (APPLIES)
- [docs/studio/hexa-main-character.md](docs/studio/hexa-main-character.md) — 🎬 Studio (DIRECTS)
- [docs/filter_algebra/hexa-filter-algebra.md](docs/filter_algebra/hexa-filter-algebra.md) — 🧮 Forge (AUTHORS)
- [docs/parallel_self/hexa-parallel-self.md](docs/parallel_self/hexa-parallel-self.md) — 🪞 Mirror (GENERATES)
- [docs/vsco/hexa-vsco.md](docs/vsco/hexa-vsco.md) — 🎨 Atelier (EDITS · LIBRARY · DISCOVER)

All five are own#15 21-section research-paper-format spec docs (own#33 ai-native-verify-pattern Block A-G).

## Lineage

Lumière absorbs the entire [n6-architecture](https://github.com/need-singularity/n6-architecture) **apps axis** — the 13th axis registered 2026-05-01 — where the 5 verb-distinct sibling domains were factored as separate research papers but share one consumer iOS surface.

## Build

Prerequisites: **macOS 15+ · Xcode 26+ · iOS 18+ deployment target**

```sh
brew install xcodegen          # one-time
xcodegen generate              # regenerate Lumiere.xcodeproj from project.yml
open Lumiere.xcodeproj
```

CLI build / test:
```sh
xcodebuild -project Lumiere.xcodeproj -scheme Lumiere \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test
```

## Repo layout

```
lumiere/
├── project.yml                 ← xcodegen spec (single source of truth)
├── Sources/Lumiere/
│   ├── LumiereApp.swift        @main · SwiftUI App
│   ├── ContentView.swift       TabView (Camera / Studio)
│   ├── Camera/                 AVFoundation real-time pipeline
│   │   ├── CameraSession.swift
│   │   ├── CameraView.swift          tab-level switcher (Filters | Mirror)
│   │   ├── FiltersCaptureView.swift  APPLIES surface
│   │   ├── MirrorView.swift          GENERATES surface (mk1 placeholder)
│   │   ├── CameraPreviewView.swift   UIViewRepresentable
│   │   └── FrameProcessor.swift  · FrameTimingRecorder.swift · …
│   ├── Studio/
│   │   ├── StudioView.swift          tab-level switcher (Direct | Edit | Author)
│   │   ├── DirectStudioView.swift    DIRECTS surface · 9-effect catalog
│   │   ├── AtelierView.swift         EDITS surface (mk1 placeholder)
│   │   ├── ForgeView.swift           AUTHORS surface (mk1 placeholder)
│   │   ├── StudioCameraView.swift    full-screen anamorphic capture sheet
│   │   └── AnamorphicFrameProcessor.swift
│   └── Assets.xcassets/        AppIcon · AccentColor
├── Tests/LumiereTests/         Swift Testing
│   ├── CinematicEffectTests.swift
│   └── PhysicalLimitTests.swift
├── docs/
│   ├── camera/camera-filter-app.md
│   ├── studio/hexa-main-character.md
│   ├── filter_algebra/hexa-filter-algebra.md
│   ├── parallel_self/hexa-parallel-self.md
│   ├── vsco/hexa-vsco.md
│   └── measurements/             F-gate measurement records
├── .roadmap.camera               mk2 per-domain JSONL roadmap (5)
├── .roadmap.studio
├── .roadmap.filter_algebra
├── .roadmap.parallel_self
├── .roadmap.vsco
├── .roadmap.release              cross-cutting TestFlight/App Store
├── fastlane/                     Fastfile + Appfile + Matchfile
├── scripts/                      F-gate measurement helpers
└── .github/workflows/
    ├── ios.yml                   GitHub Actions (build + test)
    ├── release.yml               TestFlight on v* tag
    └── measure.yml               F-gate proxy on workflow_dispatch
```

`Lumiere.xcodeproj` is git-ignored — regenerated from `project.yml` on every build.

## License

MIT — see [LICENSE](LICENSE).
