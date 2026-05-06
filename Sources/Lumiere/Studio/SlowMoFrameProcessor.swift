import CoreVideo
import Foundation

/// Lucas-Kanade 1981 optical-flow slow-motion — **scaffold only**.
///
/// Real implementation requires `VNTrackOpticalFlowRequest` (Vision
/// framework, iOS 18+) to estimate per-pixel motion vectors between
/// consecutive frames, then synthesize intermediate frames via warp
/// + cross-blend. Per spec §10 hexa-main-character Block C, the
/// pipeline budget is 1.8 ms NPU stage at 60 fps input → 240 fps
/// output (4× slow-mo).
///
/// mk1 mk2 closure: pass-through buffer with state tracking only —
/// the FrameTimingRecorder still measures pipeline overhead, so
/// F-MC-MVP-1 latency math remains honest. mk3 lands the actual
/// optical-flow + warp.
final class SlowMoFrameProcessor: FrameProcessor, @unchecked Sendable {
    private(set) var sampledFrameCount: Int = 0
    private let lock = NSLock()

    init() {}

    func process(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        lock.lock()
        sampledFrameCount += 1
        lock.unlock()
        // mk3 will:
        // 1) cache previous frame
        // 2) VNTrackOpticalFlowRequest( prev, current )
        // 3) synthesize 3 intermediates by warping + linearly blending
        // 4) emit 4 frames per input frame to downstream
        return pixelBuffer
    }
}
