import Testing
import Foundation
import CoreGraphics
@testable import Lumiere

@Suite("AnamorphicFrameProcessor crop math")
struct AnamorphicFrameProcessorTests {

    @Test("Default target aspect is 2.39:1")
    func defaultAspect() {
        let p = AnamorphicFrameProcessor()
        #expect(abs(p.targetAspect - 2.39) < 0.001)
    }

    @Test("Crop rect for 1920×1080 (16:9 input): full width, height = 1920/2.39 ≈ 803, centered")
    func standardHDInput() {
        let crop = AnamorphicFrameProcessor.cropRect(
            for: CGSize(width: 1920, height: 1080),
            targetAspect: 2.39
        )
        #expect(crop.width == 1920)
        #expect(abs(crop.height - 803.35) < 1.0)
        #expect(abs(crop.minX) < 0.001)
        #expect(abs(crop.minY - 138.32) < 1.0)
    }

    @Test("Crop rect for square input: width preserved, height = w/2.39")
    func squareInput() {
        let crop = AnamorphicFrameProcessor.cropRect(
            for: CGSize(width: 1000, height: 1000),
            targetAspect: 2.39
        )
        #expect(crop.width == 1000)
        #expect(abs(crop.height - 418.41) < 1.0)
    }

    @Test("Crop rect for portrait input (narrower-aspect than target) crops top + bottom")
    func portraitInput() {
        // 1080×1920 (9:16 portrait, aspect 0.5625) vs target 2.39 → crop top+bottom
        let crop = AnamorphicFrameProcessor.cropRect(
            for: CGSize(width: 1080, height: 1920),
            targetAspect: 2.39
        )
        #expect(crop.width == 1080)
        // newHeight = 1080 / 2.39 ≈ 451.88; centered yOffset = (1920 - 451.88)/2 ≈ 734.06
        #expect(abs(crop.height - 451.88) < 1.0)
        #expect(abs(crop.minX) < 0.001)
        #expect(abs(crop.minY - 734.06) < 1.0)
    }

    @Test("Wider-than-target input (3:1 cinemascope) crops left + right at 2.39 target")
    func ultraWideInput() {
        // 3000×1000 (aspect 3.0) vs target 2.39 → crop sides (input wider than target)
        let crop = AnamorphicFrameProcessor.cropRect(
            for: CGSize(width: 3000, height: 1000),
            targetAspect: 2.39
        )
        // newWidth = 1000 * 2.39 = 2390; xOffset = (3000 - 2390)/2 = 305
        #expect(abs(crop.width - 2390.0) < 1.0)
        #expect(crop.height == 1000)
        #expect(abs(crop.minX - 305.0) < 1.0)
        #expect(abs(crop.minY) < 0.001)
    }

    @Test("Crop rect for invalid (zero) size returns .zero")
    func zeroSize() {
        let crop = AnamorphicFrameProcessor.cropRect(
            for: CGSize(width: 0, height: 0),
            targetAspect: 2.39
        )
        #expect(crop == .zero)
    }

    @Test("Crop rect for negative aspect returns .zero")
    func negativeAspect() {
        let crop = AnamorphicFrameProcessor.cropRect(
            for: CGSize(width: 1920, height: 1080),
            targetAspect: -1.0
        )
        #expect(crop == .zero)
    }

    @Test("Custom target aspect (e.g. CinemaScope 2.55)")
    func customAspect() {
        let crop = AnamorphicFrameProcessor.cropRect(
            for: CGSize(width: 1920, height: 1080),
            targetAspect: 2.55
        )
        // 1920 / 2.55 ≈ 752.94
        #expect(crop.width == 1920)
        #expect(abs(crop.height - 752.94) < 1.0)
    }
}
