import CoreImage
import CoreVideo

/// Teal-orange grading — Hollywood 2000s color-grade signature.
/// mk1 implementation: a `CIColorMatrix` that warms reds, slightly
/// desaturates greens, and adds a cool cast to blues. A broadcast-
/// grade two-tone gradient map (shadows → teal, highlights → orange)
/// is mk3+ work; this scaffold demonstrates the FrameProcessor
/// pipeline at the studio.cond.3 effect-count level.
final class TealOrangeFrameProcessor: FrameProcessor, @unchecked Sendable {
    let warmth: CGFloat
    private let renderer: CIFrameRenderer

    init(warmth: CGFloat = 1.0) {
        self.warmth = max(0, min(2, warmth))
        self.renderer = CIFrameRenderer()
    }

    func process(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        let input = CIImage(cvPixelBuffer: pixelBuffer)
        guard let filter = CIFilter(name: "CIColorMatrix") else { return pixelBuffer }
        filter.setValue(input, forKey: kCIInputImageKey)
        let r = 1.0 + 0.08 * warmth
        let g = 1.0 - 0.03 * warmth
        let b = 1.0 + 0.04 * warmth
        filter.setValue(CIVector(x: r, y: 0,  z: 0,  w: 0), forKey: "inputRVector")
        filter.setValue(CIVector(x: 0, y: g,  z: 0,  w: 0), forKey: "inputGVector")
        filter.setValue(CIVector(x: 0, y: 0,  z: b,  w: 0), forKey: "inputBVector")
        filter.setValue(CIVector(x: 0, y: 0,  z: 0,  w: 1), forKey: "inputAVector")
        guard let output = filter.outputImage,
              let buffer = renderer.render(output, sizedFrom: pixelBuffer) else {
            return pixelBuffer
        }
        return buffer
    }
}
