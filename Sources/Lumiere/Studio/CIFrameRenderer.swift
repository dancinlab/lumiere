import CoreImage
import CoreVideo
import CoreFoundation

/// Shared CIContext + CVPixelBuffer allocation helper for CIFilter-
/// backed `FrameProcessor` implementations. Reuses one CIContext per
/// renderer (CIContext is thread-safe and expensive to construct).
final class CIFrameRenderer: @unchecked Sendable {
    let context: CIContext
    private let bufferAttributes: CFDictionary

    init() {
        self.context = CIContext(options: [.cacheIntermediates: false])
        self.bufferAttributes = [
            kCVPixelBufferIOSurfacePropertiesKey: [:] as CFDictionary,
            kCVPixelBufferMetalCompatibilityKey: true
        ] as CFDictionary
    }

    /// Render `image` into a freshly allocated 32BGRA pixel buffer
    /// matching the dimensions of `original`. Returns nil on allocation
    /// failure (caller passes through the original buffer).
    func render(_ image: CIImage, sizedFrom original: CVPixelBuffer) -> CVPixelBuffer? {
        let extent = CIImage(cvPixelBuffer: original).extent
        let cropped = image.cropped(to: extent)

        let width = CVPixelBufferGetWidth(original)
        let height = CVPixelBufferGetHeight(original)

        var newBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            bufferAttributes,
            &newBuffer
        )
        guard status == kCVReturnSuccess, let buffer = newBuffer else {
            return nil
        }
        context.render(cropped, to: buffer)
        return buffer
    }
}
