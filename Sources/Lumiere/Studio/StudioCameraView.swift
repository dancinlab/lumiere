import SwiftUI
import AVFoundation

struct StudioCameraView: View {
    /// Single shared `StudioPipeline` instance — handed to
    /// `CameraSession` as the `FrameProcessor`, and also held as a
    /// view-state reference so the toggle row can flip stages on/off
    /// live without rebuilding the camera session.
    @StateObject private var bridge: StudioPipelineBridge
    @StateObject private var session: CameraSession
    @State private var anamorphicEnabled: Bool
    @State private var enabledEffects: Set<CinematicEffect>
    @Environment(\.dismiss) private var dismiss

    private let aspectRatio: CGFloat = 2.39

    /// Initial pipeline configuration. mk4-A introduces the
    /// `fullCinematic` preset: all 5 real CIFilter stages on
    /// (anamorphic + tealOrange + lensFlare + grain + titleCard)
    /// for the spec's "main-character" composite look. The 4 scaffold
    /// stages stay off until their mk5 subsystems land.
    init(preset: StudioPreset = .anamorphicOnly) {
        let initial = preset.enabledEffects
        let bridge = StudioPipelineBridge(initialEffects: initial)
        _bridge = StateObject(wrappedValue: bridge)
        _session = StateObject(
            wrappedValue: CameraSession(processor: bridge.pipeline)
        )
        _enabledEffects = State(initialValue: initial)
        _anamorphicEnabled = State(initialValue: initial.contains(.anamorphic))
    }

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
            effectToggleRow
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

    /// Horizontally-scrolling chip row for toggling each of the 9
    /// cinematic effects in the live `StudioPipeline`. Independent
    /// of the SwiftUI `anamorphicEnabled` letterbox visual (which
    /// is purely a SwiftUI overlay).
    private var effectToggleRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(CinematicEffect.allCases) { effect in
                    let on = enabledEffects.contains(effect)
                    Button {
                        toggle(effect)
                    } label: {
                        HStack(spacing: 4) {
                            if on {
                                Image(systemName: "checkmark")
                                    .font(.caption2.weight(.bold))
                            }
                            Text(effect.shortName)
                                .font(.caption2.monospaced())
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .foregroundStyle(on ? .black : .white)
                        .background(
                            on ? AnyShapeStyle(.orange)
                               : AnyShapeStyle(.white.opacity(0.15)),
                            in: .capsule
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func toggle(_ effect: CinematicEffect) {
        if enabledEffects.contains(effect) {
            enabledEffects.remove(effect)
            bridge.pipeline.enable(effect, false)
        } else {
            enabledEffects.insert(effect)
            bridge.pipeline.enable(effect, true)
        }
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

/// Holds the single `StudioPipeline` reference so both the
/// `CameraSession` and the toggle UI mutate the same instance.
/// Wrapped in an `ObservableObject` so SwiftUI keeps it alive across
/// view updates.
@MainActor
final class StudioPipelineBridge: ObservableObject {
    let pipeline: StudioPipeline

    init(initialEffects: Set<CinematicEffect> = [.anamorphic]) {
        self.pipeline = StudioPipeline(defaultEnabled: initialEffects)
    }
}

/// Initial pipeline configuration presets for the Studio capture
/// surface. mk4-A: enumerated rather than ad-hoc Set<CinematicEffect>
/// arguments so the launcher row in `DirectStudioView` can offer
/// named entry points — anamorphic-only (Stage B legacy) vs the full
/// 5-real-effect cinematic stack.
enum StudioPreset {
    case anamorphicOnly
    case fullCinematic

    var enabledEffects: Set<CinematicEffect> {
        switch self {
        case .anamorphicOnly:
            return [.anamorphic]
        case .fullCinematic:
            // 5 real CIFilter effects per `EffectImplementationStatus`;
            // 4 scaffold stages (slow-mo / bokeh / freeze / music)
            // stay off — they are zero-cost pass-through anyway.
            return [.anamorphic, .tealOrange, .lensFlare, .grain, .titleCard]
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
