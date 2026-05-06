import CoreImage
import CoreVideo

/// Cox 1955 Kodak Vision3 5219 film-grain analog — overlay random
/// noise via `CIRandomGenerator` blended at low alpha. Per spec §10
/// hexa-main-character Block C, D50 1.4 µm grain pitch maps to ~0.15
/// alpha at 12 MP for a perceptually-correct cinematic intensity.
/// True FFT-matched grain spectrum is mk3+ work.
final class CoxGrainFrameProcessor: FrameProcessor, @unchecked Sendable {
    let intensity: CGFloat
    private let renderer: CIFrameRenderer

    init(intensity: CGFloat = 0.15) {
        self.intensity = max(0, min(1, intensity))
        self.renderer = CIFrameRenderer()
    }

    func process(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        let input = CIImage(cvPixelBuffer: pixelBuffer)
        guard let noiseFilter = CIFilter(name: "CIRandomGenerator"),
              let noise = noiseFilter.outputImage?.cropped(to: input.extent) else {
            return pixelBuffer
        }
        // Scale noise to grayscale + low alpha
        guard let alphaFilter = CIFilter(name: "CIColorMatrix") else { return pixelBuffer }
        alphaFilter.setValue(noise, forKey: kCIInputImageKey)
        alphaFilter.setValue(CIVector(x: 0.33, y: 0.33, z: 0.33, w: 0), forKey: "inputRVector")
        alphaFilter.setValue(CIVector(x: 0.33, y: 0.33, z: 0.33, w: 0), forKey: "inputGVector")
        alphaFilter.setValue(CIVector(x: 0.33, y: 0.33, z: 0.33, w: 0), forKey: "inputBVector")
        alphaFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: intensity), forKey: "inputAVector")
        guard let scaledNoise = alphaFilter.outputImage else { return pixelBuffer }

        guard let composite = CIFilter(name: "CISourceOverCompositing") else { return pixelBuffer }
        composite.setValue(scaledNoise, forKey: kCIInputImageKey)
        composite.setValue(input, forKey: kCIInputBackgroundImageKey)

        guard let output = composite.outputImage,
              let buffer = renderer.render(output, sizedFrom: pixelBuffer) else {
            return pixelBuffer
        }
        return buffer
    }
}
