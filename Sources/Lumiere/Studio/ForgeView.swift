import SwiftUI

/// hexa-filter-algebra surface — AUTHORS verb.
/// mk1 placeholder. The full surface lands at filter_algebra.cond.2/3
/// (mk2):
///   • 9 primitive ops (color matrix / tone curve / convolution /
///     color-space / grain / histogram / local-tone / vignette /
///     sharpening) closed under composition algebra
///   • 30-min auto-generation from N=5 reference image pairs
///     (He 2015 residual + linear regression on M + 1D regression on
///     T + FFT grain match)
///   • plaintext Recipe export (e.g., `f = portra ∘ vignette(0.3) ∘ grain(0.2)`)
///   • LPIPS ≤ 0.15 / SSIM ≥ 0.95 / PSNR ≥ 35 dB provable bounds
struct ForgeView: View {
    var body: some View {
        List {
            Section {
                primitiveRow(.colorMatrix)
                primitiveRow(.toneCurve)
                primitiveRow(.convolution)
                primitiveRow(.colorSpace)
                primitiveRow(.grain)
                primitiveRow(.histogram)
                primitiveRow(.localTone)
                primitiveRow(.vignette)
                primitiveRow(.sharpening)
            } header: {
                Text("9 primitive ops (algebra placeholder)")
            } footer: {
                Text("filter_algebra.cond.2 — Swift FilterAlgebra runtime is mk2")
                    .font(.caption2.monospaced())
            }

            Section {
                placeholderRow(
                    icon: "wand.and.stars",
                    title: "Author from N=5 reference pairs",
                    subtitle: "30-min inverse-problem auto-gen vs VSCO's 1–2 weeks"
                )
                placeholderRow(
                    icon: "doc.plaintext",
                    title: "Recipe export",
                    subtitle: "f = portra ∘ vignette(0.3) ∘ grain(0.2)"
                )
            } header: {
                Text("Inverse problem (placeholder)")
            } footer: {
                Text("filter_algebra.cond.3 + vsco.cond.3 (50 inaugural Recipes feed Atelier library)")
                    .font(.caption2.monospaced())
            }
        }
    }

    private func primitiveRow(_ op: FilterPrimitive) -> some View {
        HStack {
            Image(systemName: op.symbol)
                .frame(width: 28)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(op.name).font(.body)
                Text(op.anchor).font(.caption2.monospaced()).foregroundStyle(.secondary)
            }
            Spacer()
            Text("mk2").font(.caption2.monospaced()).foregroundStyle(.tertiary)
        }
        .opacity(0.7)
    }

    private func placeholderRow(icon: String, title: String, subtitle: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 28)
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body)
                Text(subtitle).font(.caption2.monospaced()).foregroundStyle(.secondary)
            }
            Spacer()
            Text("mk2").font(.caption2.monospaced()).foregroundStyle(.tertiary)
        }
        .opacity(0.7)
    }
}

enum FilterPrimitive: String, CaseIterable, Identifiable {
    case colorMatrix, toneCurve, convolution, colorSpace, grain, histogram, localTone, vignette, sharpening

    var id: String { rawValue }

    var name: String {
        switch self {
        case .colorMatrix: return "Color matrix (3×3)"
        case .toneCurve:   return "Tone curve (1D LUT)"
        case .convolution: return "Convolution (k×k)"
        case .colorSpace:  return "Color-space transform"
        case .grain:       return "Grain"
        case .histogram:   return "Histogram"
        case .localTone:   return "Local tone"
        case .vignette:    return "Vignette"
        case .sharpening:  return "Sharpening"
        }
    }

    var anchor: String {
        switch self {
        case .colorMatrix: return "linear · associative ✓"
        case .toneCurve:   return "function composition · associative"
        case .convolution: return "linear · associative ✓"
        case .colorSpace:  return "matrix · invertible"
        case .grain:       return "Cox 1955 · FFT match"
        case .histogram:   return "Shannon 1948 · DPI bound"
        case .localTone:   return "Reinhard-Devlin 2002"
        case .vignette:    return "cos⁴θ paraxial"
        case .sharpening:  return "unsharp mask · Wiener 1949"
        }
    }

    var symbol: String {
        switch self {
        case .colorMatrix: return "square.grid.3x3"
        case .toneCurve:   return "scribble.variable"
        case .convolution: return "square.dashed"
        case .colorSpace:  return "circle.hexagongrid"
        case .grain:       return "circle.grid.cross"
        case .histogram:   return "chart.bar"
        case .localTone:   return "sun.haze"
        case .vignette:    return "circle.dashed"
        case .sharpening:  return "rays"
        }
    }
}
