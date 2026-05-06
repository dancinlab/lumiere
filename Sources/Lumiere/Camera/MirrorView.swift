import SwiftUI
import AVFoundation

/// hexa-parallel-self surface — GENERATES verb.
/// Slot-machine UX: single selfie → 8-grid alternate-self generation
/// across 5 identity axes (era / culture / profession / aesthetic /
/// personal-multiverse). mk1 ships the capture-and-confirm shell + a
/// placeholder grid; the actual SD v3 + InstantID + LoRA inference
/// pipeline lands at parallel_self.cond.2 (mk2, depends on Core ML
/// scaffold camera.cond.2).
struct MirrorView: View {
    @StateObject private var session = CameraSession()
    @State private var captured = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch session.permissionState {
            case .authorized:
                if captured {
                    eightGridPlaceholder
                } else {
                    CameraPreviewView(session: session.session)
                        .ignoresSafeArea()
                        .overlay(alignment: .bottom) { captureControls }
                }
            case .denied, .restricted:
                permissionDenied
            case .notDetermined:
                ProgressView().tint(.white)
            @unknown default:
                ProgressView().tint(.white)
            }
        }
        .task { await session.requestPermissionAndStart() }
        .onDisappear { session.stop() }
    }

    private var captureControls: some View {
        VStack(spacing: 12) {
            Text("Lumière Camera · Mirror (GENERATES)")
                .font(.caption.monospaced())
                .foregroundStyle(.white.opacity(0.85))
            Button { captured = true } label: {
                Circle()
                    .fill(.white)
                    .frame(width: 72, height: 72)
                    .overlay(Circle().stroke(.white, lineWidth: 4).padding(-6))
            }
            Text("InstantID 0.85 cosine · DDIM 4-step · 18 ms p95 (mk2)")
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.bottom, 32)
    }

    private var eightGridPlaceholder: some View {
        VStack(spacing: 16) {
            Text("8-grid alternate selves")
                .font(.headline)
                .foregroundStyle(.white)
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 4),
                spacing: 4
            ) {
                ForEach(0..<8, id: \.self) { i in
                    placeholderTile(label: timelineName(i))
                }
            }
            .padding(.horizontal, 16)
            Button("Capture again") { captured = false }
                .foregroundStyle(.orange)
                .padding(.top, 8)
            Text("mk2: SD v3 + InstantID + LoRA bank · F-PSELF-MVP-1..5 issues #16–20")
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(.top, 60)
    }

    private func placeholderTile(label: String) -> some View {
        ZStack {
            Rectangle()
                .fill(.white.opacity(0.12))
                .aspectRatio(1, contentMode: .fit)
            VStack(spacing: 4) {
                Image(systemName: "person.crop.rectangle.stack")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.5))
                Text(label)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.white.opacity(0.7))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .padding(4)
        }
    }

    private func timelineName(_ i: Int) -> String {
        let labels = [
            "Renaissance", "Edo", "Belle Époque", "1980s",
            "2070s", "Cottagecore", "Cyberpunk", "Y2K"
        ]
        return labels[i % labels.count]
    }

    private var permissionDenied: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.slash")
                .font(.largeTitle)
                .foregroundStyle(.white)
            Text("Camera access required")
                .foregroundStyle(.white)
                .font(.headline)
        }
    }
}
