import Testing
import Foundation
import CoreImage
@testable import Lumiere

@Suite("AtelierPreviewRenderer — cross-domain Forge → Atelier wire")
struct AtelierPreviewTests {

    @Test("defaultSample returns a CIImage with the requested extent")
    func defaultSampleExtent() {
        let img = AtelierPreviewRenderer.defaultSample(size: CGSize(width: 64, height: 48))
        #expect(img.extent.width == 64)
        #expect(img.extent.height == 48)
    }

    @Test("render with a valid recipe yields .success with a non-nil UIImage")
    func renderValidRecipe() {
        let sample = AtelierPreviewRenderer.defaultSample(size: CGSize(width: 64, height: 64))
        let result = AtelierPreviewRenderer.render(
            recipe: "color_matrix ∘ vignette(0.3) ∘ grain(0.2)",
            sample: sample
        )
        switch result {
        case .success(let img):
            #expect(img.size.width > 0)
            #expect(img.size.height > 0)
        case .failure(let err):
            Issue.record("expected success, got \(err)")
        }
    }

    @Test("render with an unknown primitive yields .parseFailed(.unknownPrimitive)")
    func renderUnknownPrimitive() {
        let sample = AtelierPreviewRenderer.defaultSample()
        let result = AtelierPreviewRenderer.render(
            recipe: "color_matrix ∘ not_a_primitive",
            sample: sample
        )
        switch result {
        case .success:
            Issue.record("expected failure for unknown primitive")
        case .failure(let err):
            #expect(err == .parseFailed(.unknownPrimitive("not_a_primitive")))
        }
    }

    @Test("render with empty recipe yields .parseFailed(.empty)")
    func renderEmpty() {
        let sample = AtelierPreviewRenderer.defaultSample()
        let result = AtelierPreviewRenderer.render(recipe: "  ", sample: sample)
        switch result {
        case .success:
            Issue.record("expected failure for empty recipe")
        case .failure(let err):
            #expect(err == .parseFailed(.empty))
        }
    }

    @Test("Atelier inaugural library recipes ALL parse successfully")
    @MainActor
    func inauguralRecipesAllParse() {
        let library = AtelierLibrary()
        var failed: [String] = []
        for f in library.filters {
            switch RecipeParser.parse(f.recipe) {
            case .success: continue
            case .failure: failed.append(f.name)
            }
        }
        #expect(failed.isEmpty, "filters with unparseable recipes: \(failed)")
    }
}
