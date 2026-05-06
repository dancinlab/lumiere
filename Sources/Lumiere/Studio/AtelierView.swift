import SwiftUI

/// hexa-vsco surface — EDITS · LIBRARY · DISCOVER verb.
/// mk1 placeholder. The full surface lands at vsco.cond.2 (mk2):
///   • 200+ filter library + HSL panel + tone curve + Recipe + Studio
///     + Discover tab + Free vs Pro tier
///   • 7 physics-based tools (Hurter-Driffield / Wiener / Cox /
///     Planck / cos⁴θ / MacAdam / CIE 1931)
///   • plaintext Recipe URL share-load (F-VSCO-MVP-3)
///   • 70% creator royalty marketplace (mk5)
struct AtelierView: View {
    var body: some View {
        List {
            Section {
                placeholderRow(
                    icon: "photo.on.rectangle.angled",
                    title: "Library",
                    subtitle: "200+ algebra-generated filters · 50 inaugural"
                )
                placeholderRow(
                    icon: "slider.horizontal.3",
                    title: "HSL · Tone curve · Recipe",
                    subtitle: "16.67 ms p95 single-tool ceiling"
                )
                placeholderRow(
                    icon: "person.2",
                    title: "Discover",
                    subtitle: "70% creator royalty marketplace (mk5)"
                )
                placeholderRow(
                    icon: "atom",
                    title: "Physics tools",
                    subtitle: "H&D / Wiener / Cox / Planck / cos⁴θ / MacAdam / CIE 1931"
                )
            } header: {
                Text("Atelier — pro photo editor (placeholder)")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("vsco.cond.2-7 in `.roadmap.vsco` · F-VSCO-MVP-1..5 issues #21–25")
                        .font(.caption2.monospaced())
                    Text("LPIPS ≤ 0.15 / SSIM ≥ 0.95 / PSNR ≥ 35 dB provable bounds")
                        .font(.caption2.monospaced())
                }
            }
        }
    }

    private func placeholderRow(icon: String, title: String, subtitle: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 28)
                .foregroundStyle(.tint)
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
