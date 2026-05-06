import SwiftUI
import AVFoundation

/// hexa-parallel-self surface — GENERATES verb.
/// Slot-machine UX: single selfie → 8-grid alternate-self generation
/// across 5 identity axes (era / culture / profession / aesthetic /
/// personal-multiverse). mk3-C wires the capture-and-confirm shell to
/// the real `MirrorSession` runtime + `IdentityAxisBank` 8-grid;
/// SD v3 + InstantID + LoRA inference is mk4 (depends on
/// `camera.cond.2` Core ML scaffold + SD-v3 weight conversion).
struct MirrorView: View {
    @StateObject private var session = CameraSession()
    @StateObject private var mirror = MirrorSession()
    @State private var captured = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch session.permissionState {
            case .authorized:
                if captured {
                    if mirror.isGenerating {
                        generatingView
                    } else {
                        eightGridView
                    }
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
            Button {
                captured = true
                Task { await mirror.generate() }
            } label: {
                Circle()
                    .fill(.white)
                    .frame(width: 72, height: 72)
                    .overlay(Circle().stroke(.white, lineWidth: 4).padding(-6))
            }
            Text("InstantID 0.85 cosine · DDIM 4-step · 18 ms p95 (mk4)")
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.bottom, 32)
    }

    private var generatingView: some View {
        VStack(spacing: 14) {
            ProgressView().tint(.white)
            Text("Generating 8 alternate selves…")
                .font(.callout)
                .foregroundStyle(.white)
            Text("MirrorSession.generate · 18 ms design ceiling (mk3 stub)")
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var eightGridView: some View {
        VStack(spacing: 16) {
            Text("8-grid alternate selves")
                .font(.headline)
                .foregroundStyle(.white)
            Text(String(format: "generated in %.1f ms (mk3 stub)", mirror.lastGenerationMs))
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.5))
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 4),
                spacing: 4
            ) {
                ForEach(mirror.generatedTimelines) { candidate in
                    placeholderTile(candidate: candidate)
                }
            }
            .padding(.horizontal, 16)
            Button("Capture again") {
                captured = false
                mirror.reset()
            }
            .foregroundStyle(.orange)
            .padding(.top, 8)
            Text("mk4: SD v3 + InstantID + LoRA bank · F-PSELF-MVP-1..5 issues #16–20")
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(.top, 60)
    }

    private func placeholderTile(candidate: TimelineCandidate) -> some View {
        ZStack {
            Rectangle()
                .fill(.white.opacity(0.12))
                .aspectRatio(1, contentMode: .fit)
            VStack(spacing: 4) {
                Image(systemName: "person.crop.rectangle.stack")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.5))
                Text(candidate.label)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(candidate.axis.rawValue)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.orange.opacity(0.7))
            }
            .padding(4)
        }
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
