import SwiftUI
import AVFoundation

/// camera-filter-app surface — APPLIES verb.
/// Real-time filter capture with live p50/p95 timing HUD against the
/// F-CFA-MVP-1 falsifier threshold (25 ms p95 on iPhone 15 Pro).
struct FiltersCaptureView: View {
    @StateObject private var session = CameraSession()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch session.permissionState {
            case .authorized:
                CameraPreviewView(session: session.session)
                    .ignoresSafeArea()
                    .overlay(alignment: .bottom) {
                        FiltersHUD(recorder: session.recorder)
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

    private var permissionDenied: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.slash")
                .font(.largeTitle)
                .foregroundStyle(.white)
            Text("Camera access required")
                .foregroundStyle(.white)
                .font(.headline)
            Text("Enable in Settings → Privacy & Security → Camera")
                .foregroundStyle(.white.opacity(0.7))
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

private struct FiltersHUD: View {
    @ObservedObject var recorder: FrameTimingRecorder

    /// F-CFA-MVP-1 falsifier threshold (spec §19.2): p95 > 25 ms retracts
    /// the real-time claim. The HUD turns red above this value.
    private let p95FalsifierMs: Double = 25.0

    var body: some View {
        VStack(spacing: 8) {
            Text("Lumière Camera · Filters (APPLIES)")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
            Text("16.67 ms · 17.5 TOPS · Airy + Poisson")
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.5))
            if recorder.sampleCount > 0 {
                HStack(spacing: 16) {
                    metric("p50", value: recorder.p50Ms, unit: "ms", warn: false)
                    metric("p95", value: recorder.p95Ms, unit: "ms",
                           warn: recorder.p95Ms > p95FalsifierMs)
                    metric("n", value: Double(recorder.sampleCount), unit: "", warn: false)
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.black.opacity(0.35), in: .rect(cornerRadius: 12))
        .padding(.bottom, 24)
    }

    private func metric(_ label: String, value: Double, unit: String, warn: Bool) -> some View {
        VStack(spacing: 0) {
            Text(label)
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.5))
            Text(unit.isEmpty ? "\(Int(value))" : String(format: "%.1f %@", value, unit))
                .font(.caption.monospaced())
                .foregroundStyle(warn ? .red : .white.opacity(0.95))
        }
    }
}
