import CoreVideo
import Foundation

/// Depth-aware bokeh — **scaffold only**.
///
/// Real implementation consumes `AVDepthData` from the dual-camera /
/// LiDAR pipeline and applies a circular-kernel blur whose radius
/// scales with depth (foreground sharp, background bokeh). Per spec
/// §10 hexa-main-character Block C, the kernel falls back to a
/// uniform Gaussian when depth is unavailable.
///
/// mk1 mk2 closure: pass-through buffer + depth-availability flag.
/// mk3 lands the actual depth-aware variable-radius blur.
final class DepthBokehFrameProcessor: FrameProcessor, @unchecked Sendable {
    let aperture: CGFloat
    private(set) var hasDepthData: Bool = false
    private let lock = NSLock()

    init(aperture: CGFloat = 1.7) {
        self.aperture = aperture
    }

    func process(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        // mk3 will:
        // 1) read accompanying AVDepthData attached to the sample buffer
        // 2) build a per-pixel radius map = k * (focal_distance - depth)
        // 3) variable-radius Gaussian blur (Metal compute kernel)
        // 4) composite blurred + sharp via depth-derived alpha mask
        return pixelBuffer
    }
}
