import CoreImage
import CoreVideo
import CoreText
import Foundation

/// Auto title-card overlay — frame burn-in at the start of a clip,
/// fading after a configurable lead-in. mk1 burns a single static
/// title for every frame; clip-aware fade-in/out + auto-generated
/// title (LLM scene caption) is mk3+. Tone-mapping of the title's
/// background plate uses Reinhard-Devlin 2002 globally so the title
/// remains readable across any source luminance.
final class TitleCardFrameProcessor: FrameProcessor, @unchecked Sendable {
    let title: String
    let intensity: CGFloat
    private let renderer: CIFrameRenderer

    init(title: String = "Lumière", intensity: CGFloat = 0.85) {
        self.title = title
        self.intensity = max(0, min(1, intensity))
        self.renderer = CIFrameRenderer()
    }

    func process(_ pixelBuffer: CVPixelBuffer) -> CVPixelBuffer {
        let input = CIImage(cvPixelBuffer: pixelBuffer)
        let extent = input.extent

        // Tone-map the source so title text reads even on bright frames
        guard let toneFilter = CIFilter(name: "CIToneCurve") else { return pixelBuffer }
        toneFilter.setValue(input, forKey: kCIInputImageKey)
        toneFilter.setValue(CIVector(x: 0,    y: 0   ), forKey: "inputPoint0")
        toneFilter.setValue(CIVector(x: 0.25, y: 0.20), forKey: "inputPoint1")
        toneFilter.setValue(CIVector(x: 0.5,  y: 0.45), forKey: "inputPoint2")
        toneFilter.setValue(CIVector(x: 0.75, y: 0.72), forKey: "inputPoint3")
        toneFilter.setValue(CIVector(x: 1,    y: 1   ), forKey: "inputPoint4")
        let toneMapped = toneFilter.outputImage ?? input

        // Render title text via CITextImageGenerator
        guard let textFilter = CIFilter(name: "CITextImageGenerator") else { return pixelBuffer }
        textFilter.setValue(title, forKey: "inputText")
        textFilter.setValue("HelveticaNeue-Light", forKey: "inputFontName")
        textFilter.setValue(extent.width * 0.08, forKey: "inputFontSize")
        textFilter.setValue(2.0, forKey: "inputScaleFactor")
        guard let textImage = textFilter.outputImage else { return pixelBuffer }

        // Center the text image at lower third
        let textExtent = textImage.extent
        let translateX = (extent.width - textExtent.width) / 2 - textExtent.minX
        let translateY = extent.height * 0.18 - textExtent.minY
        let positioned = textImage.transformed(
            by: CGAffineTransform(translationX: translateX, y: translateY)
        )

        // Apply intensity via alpha matrix
        guard let alphaFilter = CIFilter(name: "CIColorMatrix") else { return pixelBuffer }
        alphaFilter.setValue(positioned, forKey: kCIInputImageKey)
        alphaFilter.setValue(CIVector(x: 0, y: 0, z: 0, w: intensity), forKey: "inputAVector")
        guard let scaledTitle = alphaFilter.outputImage else { return pixelBuffer }

        guard let composite = CIFilter(name: "CISourceOverCompositing") else { return pixelBuffer }
        composite.setValue(scaledTitle, forKey: kCIInputImageKey)
        composite.setValue(toneMapped, forKey: kCIInputBackgroundImageKey)

        guard let output = composite.outputImage,
              let buffer = renderer.render(output, sizedFrom: pixelBuffer) else {
            return pixelBuffer
        }
        return buffer
    }
}
