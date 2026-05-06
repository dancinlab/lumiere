import SwiftUI
import AVFoundation

/// hexa-parallel-self surface — GENERATES verb.
/// Slot-machine UX: single selfie → 8-grid alternate-self generation
/// across 5 identity axes. mk4-C closure: the "Capture" button now
/// drives a real `AVCapturePhotoOutput` round-trip via
/// `PhotoCaptureCoordinator` and feeds the resulting CVPixelBuffer
/// into `MirrorSession.generate(from:)`. SD v3 + InstantID + LoRA
/// inference itself is still stubbed (mk5 — `parallel_self.cond.2`
/// pending SD-v3 weight conversion).
struct MirrorView: View {
    @StateObject private var session = CameraSession(enablePhotoCapture: true)
    @StateObject private var mirror = MirrorSession()
    @State private var captured = false
    @State private var captureError: String?

    private let coordinator = PhotoCaptureCoordinator()

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
                Task { await runCapture() }
            } label: {
                Circle()
                    .fill(.white)
                    .frame(width: 72, height: 72)
                    .overlay(Circle().stroke(.white, lineWidth: 4).padding(-6))
            }
            if let captureError {
                Text(captureError)
                    .font(.caption2.monospaced())
                    .foregroundStyle(.red.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            } else {
                Text("InstantID 0.85 cosine · DDIM 4-step · 18 ms p95 (mk5)")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.bottom, 32)
    }

    private var generatingView: some View {
        VStack(spacing: 14) {
            ProgressView().tint(.white)
            Text("Generating 8 alternate selves…")
                .font(.callout)
                .foregroundStyle(.white)
            Text("MirrorSession.generate · 18 ms design ceiling (mk4-C real photo capture)")
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.5))
        }
    }

    private var eightGridView: some View {
        VStack(spacing: 16) {
            Text("8-grid alternate selves")
                .font(.headline)
                .foregroundStyle(.white)
            captureSummary
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
                captureError = nil
                mirror.reset()
            }
            .foregroundStyle(.orange)
            .padding(.top, 8)
            Text("mk5: SD v3 + InstantID + LoRA bank · F-PSELF-MVP-1..5 issues #16–20")
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
        }
        .padding(.top, 60)
    }

    private var captureSummary: some View {
        VStack(spacing: 4) {
            if let dims = mirror.lastSelfieDimensions {
                Text("source \(Int(dims.width))×\(Int(dims.height)) px · AVCapturePhotoOutput ✓")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.green)
            } else {
                Text("source missing — mk5 stub fallback")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.orange)
            }
            Text(String(format: "generated in %.1f ms (mk4-C scaffold)", mirror.lastGenerationMs))
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.5))
        }
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

    // MARK: - Capture flow

    private func runCapture() async {
        captureError = nil
        captured = true

        guard let output = session.photoOutput else {
            await mirror.generate(from: nil)
            captureError = "photo output unavailable — fell back to mk5 stub"
            return
        }
        do {
            let buffer = try await coordinator.capturePhoto(from: output)
            await mirror.generate(from: buffer)
        } catch {
            captureError = "capture failed: \(error.localizedDescription) — fell back to mk5 stub"
            await mirror.generate(from: nil)
        }
    }
}
