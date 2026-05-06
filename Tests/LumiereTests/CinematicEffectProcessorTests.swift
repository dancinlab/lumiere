import Testing
import Foundation
import CoreVideo
@testable import Lumiere

@Suite("Cinematic FrameProcessor implementations")
struct CinematicEffectProcessorTests {

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

    // MARK: real CIFilter-backed effects

    @Test("TealOrangeFrameProcessor returns a buffer of the same dimensions")
    func tealOrangeRound() {
        let buf = makeBuffer()
        let p = TealOrangeFrameProcessor()
        let out = p.process(buf)
        #expect(CVPixelBufferGetWidth(out) == CVPixelBufferGetWidth(buf))
        #expect(CVPixelBufferGetHeight(out) == CVPixelBufferGetHeight(buf))
    }

    @Test("TealOrangeFrameProcessor warmth clamped to [0, 2]")
    func tealOrangeWarmthClamp() {
        #expect(TealOrangeFrameProcessor(warmth: -5).warmth == 0)
        #expect(TealOrangeFrameProcessor(warmth: 100).warmth == 2)
    }

    @Test("CoxGrainFrameProcessor returns same dimensions")
    func coxGrainRound() {
        let buf = makeBuffer()
        let p = CoxGrainFrameProcessor()
        let out = p.process(buf)
        #expect(CVPixelBufferGetWidth(out) == CVPixelBufferGetWidth(buf))
    }

    @Test("CoxGrainFrameProcessor intensity clamped to [0, 1]")
    func coxGrainIntensityClamp() {
        #expect(CoxGrainFrameProcessor(intensity: -1).intensity == 0)
        #expect(CoxGrainFrameProcessor(intensity: 5).intensity == 1)
    }

    @Test("LensFlareFrameProcessor returns same dimensions")
    func lensFlareRound() {
        let buf = makeBuffer()
        let p = LensFlareFrameProcessor()
        let out = p.process(buf)
        #expect(CVPixelBufferGetWidth(out) == CVPixelBufferGetWidth(buf))
    }

    @Test("TitleCardFrameProcessor returns same dimensions and stores title")
    func titleCardRound() {
        let buf = makeBuffer(width: 256, height: 256)
        let p = TitleCardFrameProcessor(title: "TEST")
        let out = p.process(buf)
        #expect(p.title == "TEST")
        #expect(CVPixelBufferGetWidth(out) == 256)
    }

    // MARK: scaffold (pass-through) effects

    @Test("SlowMoFrameProcessor is identity (mk2 scaffold) and counts samples")
    func slowMoIdentity() {
        let buf = makeBuffer()
        let p = SlowMoFrameProcessor()
        for _ in 0..<3 { _ = p.process(buf) }
        #expect(p.sampledFrameCount == 3)
    }

    @Test("DepthBokehFrameProcessor is identity (mk2 scaffold)")
    func depthBokehIdentity() {
        let buf = makeBuffer()
        let p = DepthBokehFrameProcessor()
        let out = p.process(buf)
        #expect(out === buf)
        #expect(p.hasDepthData == false)
    }

    @Test("FreezeFrameProcessor holds the trigger frame")
    func freezeHoldsFrame() {
        let buf1 = makeBuffer(width: 64)
        let buf2 = makeBuffer(width: 128)
        let p = FreezeFrameProcessor()
        _ = p.process(buf1)
        p.triggerFreeze()
        let held = p.process(buf1)
        #expect(p.isFrozen == true)
        #expect(held === buf1)
        // Subsequent frame still returns the held buffer
        let stillHeld = p.process(buf2)
        #expect(stillHeld === buf1)
        p.release()
        let after = p.process(buf2)
        #expect(after === buf2)
    }

    @Test("CLAPMusicFrameProcessor is identity and counts fingerprints")
    func clapMusicIdentity() {
        let buf = makeBuffer()
        let p = CLAPMusicFrameProcessor()
        for _ in 0..<5 { _ = p.process(buf) }
        #expect(p.sceneFingerprintCount == 5)
    }
}
