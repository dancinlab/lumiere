import SwiftUI

struct StudioView: View {
    private let effects: [CinematicEffect] = CinematicEffect.allCases
    @State private var showAnamorphicCapture = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showAnamorphicCapture = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.ratio.16.to.9")
                                .frame(width: 28)
                                .foregroundStyle(.orange)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Try Anamorphic 2.39:1").foregroundStyle(.primary)
                                Text("first of 9 effects · Stage B").font(.caption2.monospaced()).foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("Live")
                }

                Section {
                    ForEach(effects) { effect in
                        EffectRow(
                            effect: effect,
                            implemented: effect == .anamorphic
                        )
                    }
                } header: {
                    Text("9 cinematic effects")
                } footer: {
                    Text("Pipeline ceiling: 16.67 ms p95 · 12-stage decomposition · F-MC-MVP-1..5 gates 2026-08-30 / 2026-09-30")
                        .font(.caption2)
                }
            }
            .navigationTitle("Lumière Studio")
            .fullScreenCover(isPresented: $showAnamorphicCapture) {
                StudioCameraView()
            }
        }
    }
}

private struct EffectRow: View {
    let effect: CinematicEffect
    let implemented: Bool

    var body: some View {
        HStack {
            Image(systemName: effect.symbol)
                .frame(width: 28)
                .foregroundStyle(implemented ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
            VStack(alignment: .leading, spacing: 2) {
                Text(effect.name).font(.body)
                Text(effect.anchor).font(.caption2.monospaced()).foregroundStyle(.secondary)
            }
            Spacer()
            if implemented {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.caption)
            } else {
                Text("mk2")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.tertiary)
            }
        }
        .opacity(implemented ? 1.0 : 0.6)
    }
}

enum CinematicEffect: String, CaseIterable, Identifiable {
    case anamorphic, tealOrange, slowMo, bokeh, lensFlare, grain, freeze, music, titleCard

    var id: String { rawValue }

    var name: String {
        switch self {
        case .anamorphic:  return "Anamorphic 2.39:1"
        case .tealOrange:  return "Teal-orange grading"
        case .slowMo:      return "Lucas-Kanade slow-mo"
        case .bokeh:       return "Depth bokeh"
        case .lensFlare:   return "6-blade lens flare"
        case .grain:       return "Cox grain (Vision3 5219)"
        case .freeze:      return "Decisive-moment freeze"
        case .music:       return "CLAP scene-music"
        case .titleCard:   return "Auto title card"
        }
    }

    var anchor: String {
        switch self {
        case .anamorphic:  return "Cinerama 1953"
        case .tealOrange:  return "Hollywood grading 2000s"
        case .slowMo:      return "Lucas-Kanade 1981"
        case .bokeh:       return "depth-aware blur"
        case .lensFlare:   return "Snell + Fresnel · 6-blade"
        case .grain:       return "Cox 1955 · D50 1.4 µm"
        case .freeze:      return "Cartier-Bresson"
        case .music:       return "Wu CLAP 2023"
        case .titleCard:   return "Reinhard-Devlin 2002 tone"
        }
    }

    var symbol: String {
        switch self {
        case .anamorphic:  return "rectangle.ratio.16.to.9"
        case .tealOrange:  return "paintpalette"
        case .slowMo:      return "tortoise"
        case .bokeh:       return "circle.dotted"
        case .lensFlare:   return "sun.max"
        case .grain:       return "circle.grid.cross"
        case .freeze:      return "snowflake"
        case .music:       return "music.note"
        case .titleCard:   return "textformat"
        }
    }
}

#Preview {
    StudioView()
}
