import CoreImage
import UIKit
import Foundation

/// Bridges the Forge `FilterComposition` runtime into the Atelier
/// editor preview. mk4-B closure: when the user picks a
/// `LibraryFilter`, parse its `recipe` string via `RecipeParser` →
/// build a `FilterComposition` → run it on a sample `CIImage` →
/// surface the rendered result as a `UIImage` for SwiftUI display.
///
/// This is the cross-domain wire the spec calls for in
/// `.roadmap.vsco` cond.2 ("editor surface drives a Recipe through
/// the Forge runtime against a sample image"). mk5 replaces the
/// fixed sample bitmap with a user-selected photo + on-device LPIPS
/// scoring per `F-VSCO-MVP-4`.
enum AtelierPreviewRenderer {

    enum RenderError: Error, Equatable {
        case parseFailed(RecipeParseError)
        case renderFailed
    }

    /// Render the recipe through the algebra and return a UIImage.
    /// - Parameters:
    ///   - recipe: Forge-grammar Recipe string (e.g.
    ///     `color_matrix ∘ vignette(0.3) ∘ grain(0.2)`).
    ///   - sample: Source bitmap to filter through the composition.
    /// - Returns: Rendered UIImage or a `RenderError` if the parser
    ///   fails or CIContext rendering produces no output.
    static func render(recipe: String, sample: CIImage) -> Result<UIImage, RenderError> {
        switch RecipeParser.parse(recipe) {
        case .failure(let parseError):
            return .failure(.parseFailed(parseError))
        case .success(let composition):
            let processed = composition.apply(to: sample)
            let context = CIContext(options: [.cacheIntermediates: false])
            guard let cg = context.createCGImage(processed, from: processed.extent) else {
                return .failure(.renderFailed)
            }
            return .success(UIImage(cgImage: cg))
        }
    }

    /// Generate a fixed deterministic gradient as the mk4 sample
    /// bitmap. mk5 replaces this with a user-selected photo from
    /// `PHPickerViewController`.
    static func defaultSample(size: CGSize = CGSize(width: 256, height: 256)) -> CIImage {
        let gradient = CIFilter(name: "CILinearGradient")!
        gradient.setValue(CIVector(x: 0, y: 0), forKey: "inputPoint0")
        gradient.setValue(CIVector(x: size.width, y: size.height), forKey: "inputPoint1")
        gradient.setValue(CIColor(red: 0.95, green: 0.55, blue: 0.30), forKey: "inputColor0")
        gradient.setValue(CIColor(red: 0.10, green: 0.30, blue: 0.55), forKey: "inputColor1")
        let extent = CGRect(origin: .zero, size: size)
        return gradient.outputImage?.cropped(to: extent)
            ?? CIImage(color: CIColor(red: 0.5, green: 0.5, blue: 0.5)).cropped(to: extent)
    }
}
