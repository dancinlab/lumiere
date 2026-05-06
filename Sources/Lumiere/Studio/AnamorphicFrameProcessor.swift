import CoreVideo
import CoreImage
import CoreFoundation
import Foundation

/// Anamorphic 2.39:1 crop — first of 9 cinematic effects (spec §10
/// hexa-main-character / Cinerama 1953 lineage). Returns a new
/// pixel buffer cropped to the target aspect, centered. mk1 uses
/// `CIContext` for the actual GPU-backed render; the visual letterbox
/// in `StudioCameraView` is provided by a SwiftUI overlay so this
/// processor's output exercises the FrameTimingRecorder pipeline
/// without yet replacing the AVCaptureVideoPreviewLayer feed (mk2).
final class AnamorphicFrameProcessor: FrameProcessor, @unchecked Sendable {
    let targetAspect: CGFloat
    private let context: CIContext
    private let bufferAttributes: CFDictionary

    init(targetAspect: CGFloat = 2.39) {
        self.targetAspect = targetAspect
        self.context = CIContext(options: [.cacheIntermediates: false])
        self.bufferAttributes = [
            kCVPixelBufferIOSurfacePropertiesKey: [:] as CFDictionary,
            kCVPixelBufferMetalCompatibilityKey: true
        ] as CFDictionary
    }

    /// Centered crop rect for `size` against `targetAspect` (W/H).
    /// - Wider input than target (e.g. 16:9 = 1.778 vs 2.39): crop top + bottom.
    /// - Narrower input than target: crop left + right.
    static func cropRect(for size: CGSize, targetAspect: CGFloat) -> CGRect {
        guard size.width > 0, size.height > 0, targetAspect > 0 else {
            return .zero
        }
        let inputAspect = size.width / size.height
        if inputAspect >= targetAspect {
            let newHeight = size.width / targetAspect
            let yOffset = (size.height - newHeight) / 2
            return CGRect(x: 0, y: yOffset, width: size.width, height: newHeight)
        } else {
            let newWidth = size.height * targetAspect
            let xOffset = (size.width - newWidth) / 2
            return CGRect(x: xOffset, y: 0, width: newWidth, height: size.height)
        }
    }

    func process(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let crop = Self.cropRect(
            for: CGSize(width: width, height: height),
            targetAspect: targetAspect
        )
        guard crop.width > 1, crop.height > 1 else { return pixelBuffer }

        let ci = CIImage(cvPixelBuffer: pixelBuffer)
            .cropped(to: crop)
            .transformed(by: CGAffineTransform(translationX: -crop.minX, y: -crop.minY))

        var outBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(crop.width),
            Int(crop.height),
            kCVPixelFormatType_32BGRA,
            bufferAttributes,
            &outBuffer
        )
        guard status == kCVReturnSuccess, let out = outBuffer else {
            return pixelBuffer
        }

        context.render(ci, to: out)
        return out
    }
}
