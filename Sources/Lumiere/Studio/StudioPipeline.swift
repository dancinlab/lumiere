import CoreVideo
import Foundation

/// `StudioPipeline` chains the 9 cinematic `FrameProcessor` classes
/// (5 real CIFilter + 4 scaffold) into a single ordered pipeline that
/// itself conforms to `FrameProcessor`. A `CameraSession` can drive
/// the entire chain through the existing `CameraSampleBufferDelegate`
/// plumbing — `FrameTimingRecorder` keeps measuring the wall-clock
/// cost of every enabled stage, exactly what F-MC-MVP-1 (p95 ≤ 25 ms,
/// 12-stage decomposition with 0.17 ms slack — spec §10
/// hexa-main-character ARCHITECTURE) needs.
///
/// Order matches the cinematic post-pipeline lineage:
///   1. anamorphic    — geometric crop first, affects all downstream
///   2. depth-bokeh   — depth-aware blur on the cropped frame
///   3. teal-orange   — color grade
///   4. lens-flare    — additive overlay over graded image
///   5. cox-grain     — film grain on top of graded image
///   6. slow-mo       — temporal stage; last in spatial chain
///   7. freeze        — state-based hold
///   8. clap-music    — audio side-effect, identity for buffer
///   9. title-card    — final overlay so the title survives upstream
///
/// Disabled entries pass through. Scaffold processors (slow-mo /
/// bokeh / freeze / CLAP-music) are pass-through, so enabling them is
/// free except for the recorded sample-count side effects — exactly
/// what F-MC-MVP-1 latency math needs at the structural-integration
/// stage of studio.cond.3.
final class StudioPipeline: FrameProcessor, @unchecked Sendable {

    /// One ordered stage in the pipeline.
    struct Stage {
        let effect: CinematicEffect
        var isEnabled: Bool
        let processor: any FrameProcessor
    }

    /// Default cinematic post-pipeline order. Mutated only via
    /// `enable(_:_:)` on the underlying lock.
    private(set) var stages: [Stage]
    private let lock = NSLock()

    /// Default order applied at construction. The 9 effects are
    /// instantiated with their library defaults; pass `defaultEnabled`
    /// to flip individual stages on at start-up.
    init(defaultEnabled: Set<CinematicEffect> = []) {
        let ordered: [(CinematicEffect, any FrameProcessor)] = [
            (.anamorphic, AnamorphicFrameProcessor()),
            (.bokeh,      DepthBokehFrameProcessor()),
            (.tealOrange, TealOrangeFrameProcessor()),
            (.lensFlare,  LensFlareFrameProcessor()),
            (.grain,      CoxGrainFrameProcessor()),
            (.slowMo,     SlowMoFrameProcessor()),
            (.freeze,     FreezeFrameProcessor()),
            (.music,      CLAPMusicFrameProcessor()),
            (.titleCard,  TitleCardFrameProcessor())
        ]
        self.stages = ordered.map { effect, processor in
            Stage(
                effect: effect,
                isEnabled: defaultEnabled.contains(effect),
                processor: processor
            )
        }
    }

    /// Walk the chain and apply every enabled processor in order.
    /// Disabled stages pass through. Lock is held only long enough
    /// to snapshot the per-stage enabled flags + processor refs so
    /// the heavy CIFilter / CIContext work runs without contention
    /// between toggle UI and the AVCaptureVideoDataOutput queue.
    func process(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        lock.lock()
        let snapshot = stages
        lock.unlock()

        var current = pixelBuffer
        for stage in snapshot where stage.isEnabled {
            current = stage.processor.process(current)
        }
        return current
    }

    /// Toggle a stage on or off. No-op if the effect is not in the
    /// pipeline (defensive — every CinematicEffect case is wired in
    /// the default init).
    func enable(_ effect: CinematicEffect, _ on: Bool) {
        lock.lock()
        if let idx = stages.firstIndex(where: { $0.effect == effect }) {
            stages[idx].isEnabled = on
        }
        lock.unlock()
    }

    /// Current enabled-stage set, snapshot under the lock.
    var enabledEffects: Set<CinematicEffect> {
        lock.lock()
        defer { lock.unlock() }
        return Set(stages.filter { $0.isEnabled }.map { $0.effect })
    }

    /// Look up the underlying processor for an effect so callers can
    /// reach scaffold state surfaces — e.g.
    /// `pipeline.processor(for: .freeze) as? FreezeFrameProcessor`
    /// to call `triggerFreeze()`, or `as? SlowMoFrameProcessor` to
    /// read `sampledFrameCount`.
    func processor(for effect: CinematicEffect) -> (any FrameProcessor)? {
        lock.lock()
        defer { lock.unlock() }
        return stages.first(where: { $0.effect == effect })?.processor
    }
}
