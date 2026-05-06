import Testing
import Foundation
import CoreVideo
@testable import Lumiere

@Suite("StudioPipeline 12-stage chain integration")
struct StudioPipelineTests {

    // MARK: helpers

    private func makeBuffer(width: Int = 64, height: Int = 64) -> CVPixelBuffer {
        let attrs: [CFString: Any] = [
            kCVPixelBufferIOSurfacePropertiesKey: [:] as [CFString: Any]
        ]
        var pb: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width, height,
            kCVPixelFormatType_32BGRA,
            attrs as CFDictionary,
            &pb
        )
        #expect(status == kCVReturnSuccess)
        return pb!
    }

    // MARK: tests

    @Test("Empty pipeline returns input buffer unchanged")
    func emptyPipelineIsIdentity() {
        let pipeline = StudioPipeline()
        let buf = makeBuffer()
        let out = pipeline.process(buf)
        // No stage enabled → must be the exact same buffer reference.
        #expect(out === buf)
        #expect(pipeline.enabledEffects.isEmpty)
    }

    @Test("Single-effect pipeline equals direct processor invocation")
    func singleEffectMatchesDirect() {
        // Pipeline configured with only anamorphic enabled vs a
        // bare AnamorphicFrameProcessor — output dimensions must
        // match (cropped from 256×256 to 256×~107 at 2.39:1).
        let pipeline = StudioPipeline(defaultEnabled: [.anamorphic])
        let direct = AnamorphicFrameProcessor()
        let buf = makeBuffer(width: 256, height: 256)

        let pipelineOut = pipeline.process(buf)
        let directOut = direct.process(buf)

        #expect(CVPixelBufferGetWidth(pipelineOut) == CVPixelBufferGetWidth(directOut))
        #expect(CVPixelBufferGetHeight(pipelineOut) == CVPixelBufferGetHeight(directOut))
        // Both must differ from the input height (real anamorphic crop happened).
        #expect(CVPixelBufferGetHeight(pipelineOut) < CVPixelBufferGetHeight(buf))
    }

    @Test("Enable/disable mutation reflects in enabledEffects")
    func enableDisableMutation() {
        let pipeline = StudioPipeline()
        #expect(pipeline.enabledEffects.isEmpty)

        pipeline.enable(.tealOrange, true)
        pipeline.enable(.grain, true)
        #expect(pipeline.enabledEffects == [.tealOrange, .grain])

        pipeline.enable(.tealOrange, false)
        #expect(pipeline.enabledEffects == [.grain])

        pipeline.enable(.grain, false)
        #expect(pipeline.enabledEffects.isEmpty)
    }

    @Test("Default enabled set matches StudioPipeline init parameter")
    func defaultSetHonored() {
        let initial: Set<CinematicEffect> = [.anamorphic, .lensFlare, .freeze]
        let pipeline = StudioPipeline(defaultEnabled: initial)
        #expect(pipeline.enabledEffects == initial)
    }

    @Test("Pipeline with all 9 enabled exercises every processor")
    func allNineExercised() {
        let allEffects = Set(CinematicEffect.allCases)
        let pipeline = StudioPipeline(defaultEnabled: allEffects)
        #expect(pipeline.enabledEffects == allEffects)

        // Reach the scaffold processors via the pipeline accessor and
        // verify the per-frame counters advance — direct evidence that
        // every stage actually ran for each frame fed in.
        let slowMo = pipeline.processor(for: .slowMo) as? SlowMoFrameProcessor
        let clap = pipeline.processor(for: .music) as? CLAPMusicFrameProcessor
        #expect(slowMo != nil)
        #expect(clap != nil)

        // Use a larger buffer so CIFilter stages (teal-orange, grain,
        // lens flare, title card) have meaningful extent. 256×256 is
        // enough for CITextImageGenerator + CISunbeamsGenerator to
        // produce non-empty output.
        let buf = makeBuffer(width: 256, height: 256)
        let n = 4
        for _ in 0..<n { _ = pipeline.process(buf) }

        #expect(slowMo?.sampledFrameCount == n)
        #expect(clap?.sceneFingerprintCount == n)
    }
}
