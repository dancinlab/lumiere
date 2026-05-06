import CoreVideo

/// Single-frame transform stage. Implementations may be the identity (mk1
/// placeholder), a Core Image filter chain, a Metal compute pass, or a
/// Core ML inference call. Called on the AVCaptureVideoDataOutput sample
/// buffer queue (a background queue), so implementations must be
/// thread-safe with respect to that queue.
protocol FrameProcessor: AnyObject, Sendable {
    func process(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer
}

/// mk1 placeholder. Returns the input pixel buffer unmodified, so the
/// surrounding `FrameTimingRecorder` measures only the AVFoundation
/// capture-and-deliver overhead — the empirical noise floor of the
/// F-CFA-MVP-1 latency budget before any model is plugged in.
final class IdentityFrameProcessor: FrameProcessor {
    func process(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        pixelBuffer
    }
}
