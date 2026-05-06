@preconcurrency import CoreVideo
import Foundation

/// Decisive-moment freeze — **scaffold only**.
///
/// Real implementation: a Vision-based saliency / scene-classifier
/// fires when the current frame matches a "decisive moment" pattern
/// (Cartier-Bresson — peak action / expression / composition). The
/// processor then holds that frame for ~250 ms before resuming.
///
/// mk1 mk2 closure: holds whatever frame was active when
/// `triggerFreeze()` is called; auto-trigger via Vision is mk3.
/// Useful for manual hotkey-driven freeze in the meantime.
final class FreezeFrameProcessor: FrameProcessor, @unchecked Sendable {
    private(set) var isFrozen: Bool = false
    private var heldBuffer: CVPixelBuffer?
    private let lock = NSLock()

    init() {}

    func triggerFreeze() {
        lock.lock()
        isFrozen = true
        lock.unlock()
    }

    func release() {
        lock.lock()
        isFrozen = false
        heldBuffer = nil
        lock.unlock()
    }

    func process(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        lock.lock()
        defer { lock.unlock() }
        if isFrozen {
            if let held = heldBuffer { return held }
            heldBuffer = pixelBuffer
            return pixelBuffer
        } else {
            heldBuffer = nil
            return pixelBuffer
        }
    }
}
