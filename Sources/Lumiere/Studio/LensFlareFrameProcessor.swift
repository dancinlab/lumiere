import CoreImage
import CoreVideo

/// 6-blade hexagonal-aperture lens-flare overlay. mk1 implementation:
/// a `CISunbeams` filter centered at frame midpoint with 6 sun-radius
/// modulation matching the spec's hex-aperture model (§10
/// hexa-main-character Block D — Snell + Fresnel paraxial). Light-
/// source detection (Vision saliency map) + per-frame flare position
/// is mk3+; mk1 anchors the flare at the upper-third frame coordinate
/// to demonstrate the effect family.
final class LensFlareFrameProcessor: FrameProcessor, @unchecked Sendable {
    let intensity: CGFloat
    private let renderer: CIFrameRenderer

    init(intensity: CGFloat = 0.4) {
        self.intensity = max(0, min(1, intensity))
        self.renderer = CIFrameRenderer()
    }

    func process(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        let input = CIImage(cvPixelBuffer: pixelBuffer)
        guard let beams = CIFilter(name: "CISunbeamsGenerator") else { return pixelBuffer }
        let cx = input.extent.midX
        let cy = input.extent.midY * 1.4   // upper third
        beams.setValue(CIVector(x: cx, y: cy), forKey: "inputCenter")
        beams.setValue(input.extent.width * 0.06, forKey: "inputSunRadius")
        beams.setValue(input.extent.width * 0.45, forKey: "inputMaxStriationRadius")
        beams.setValue(2.0, forKey: "inputStriationStrength")
        beams.setValue(0.5, forKey: "inputStriationContrast")
        guard let beamImage = beams.outputImage?.cropped(to: input.extent) else {
            return pixelBuffer
        }

        // Scale flare alpha by intensity
        guard let alphaFilter = CIFilter(name: "CIColorMatrix") else { return pixelBuffer }
        alphaFilter.setValue(beamImage, forKey: kCIInputImageKey)
        alphaFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: intensity), forKey: "inputAVector")
        guard let scaledFlare = alphaFilter.outputImage else { return pixelBuffer }

        guard let composite = CIFilter(name: "CIScreenBlendMode") else { return pixelBuffer }
        composite.setValue(scaledFlare, forKey: kCIInputImageKey)
        composite.setValue(input, forKey: kCIInputBackgroundImageKey)

        guard let output = composite.outputImage,
              let buffer = renderer.render(output, sizedFrom: pixelBuffer) else {
            return pixelBuffer
        }
        return buffer
    }
}
