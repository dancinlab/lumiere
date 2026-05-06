import SwiftUI
import AVFoundation

struct StudioCameraView: View {
    @StateObject private var session = CameraSession(
        processor: AnamorphicFrameProcessor()
    )
    @State private var anamorphicEnabled = true
    @Environment(\.dismiss) private var dismiss

    private let aspectRatio: CGFloat = 2.39

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch session.permissionState {
            case .authorized:
                CameraPreviewView(session: session.session)
                    .ignoresSafeArea()
                    .overlay {
                        if anamorphicEnabled {
                            AnamorphicLetterbox(aspect: aspectRatio)
                                .allowsHitTesting(false)
                        }
                    }
                    .overlay(alignment: .top) { topBar }
                    .overlay(alignment: .bottom) { controls }
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

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.black.opacity(0.45), in: .circle)
            }
            Spacer()
            Text("Anamorphic 2.39:1")
                .font(.caption.monospaced())
                .foregroundStyle(.white.opacity(0.85))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.black.opacity(0.45), in: .capsule)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var controls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                metric("p50", value: session.recorder.p50Ms)
                metric("p95", value: session.recorder.p95Ms,
                       warn: session.recorder.p95Ms > 25.0)
                metric("n", value: Double(session.recorder.sampleCount), unit: "")
            }
            Toggle("Anamorphic 2.39:1 letterbox", isOn: $anamorphicEnabled)
                .tint(.orange)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.black.opacity(0.5), in: .rect(cornerRadius: 16))
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
    }

    private func metric(_ label: String, value: Double, unit: String = "ms", warn: Bool = false) -> some View {
        VStack(spacing: 0) {
            Text(label)
                .font(.caption2.monospaced())
                .foregroundStyle(.white.opacity(0.5))
            Text(unit.isEmpty ? "\(Int(value))" : String(format: "%.1f %@", value, unit))
                .font(.caption.monospaced())
                .foregroundStyle(warn ? .red : .white.opacity(0.95))
        }
        .frame(maxWidth: .infinity)
    }

    private var permissionDenied: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.slash")
                .font(.largeTitle)
                .foregroundStyle(.white)
            Text("Camera access required")
                .foregroundStyle(.white)
                .font(.headline)
            Button("Close") { dismiss() }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
        }
    }
}

private struct AnamorphicLetterbox: View {
    let aspect: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let videoHeight = size.width / aspect
            let barHeight = max(0, (size.height - videoHeight) / 2)
            VStack(spacing: 0) {
                Color.black.frame(height: barHeight)
                Spacer(minLength: 0)
                Color.black.frame(height: barHeight)
            }
        }
        .ignoresSafeArea()
    }
}
