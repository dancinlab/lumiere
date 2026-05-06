import Testing
@testable import Lumiere

@Suite("FrameTimingRecorder percentile + rolling window")
@MainActor
struct FrameTimingRecorderTests {

    @Test("Empty recorder reports zero")
    func emptyZero() {
        let r = FrameTimingRecorder()
        #expect(r.sampleCount == 0)
        #expect(r.p50Ms == 0)
        #expect(r.p95Ms == 0)
    }

    @Test("p50 of 1...100 ≈ 50")
    func p50OfHundred() {
        let r = FrameTimingRecorder(maxSamples: 1000)
        for i in 1...100 { r.record(Double(i)) }
        #expect(r.sampleCount == 100)
        #expect(abs(r.p50Ms - 50.0) <= 1.0)
    }

    @Test("p95 of 1...100 ≈ 95")
    func p95OfHundred() {
        let r = FrameTimingRecorder(maxSamples: 1000)
        for i in 1...100 { r.record(Double(i)) }
        #expect(abs(r.p95Ms - 95.0) <= 1.0)
    }

    @Test("Rolling window discards oldest beyond maxSamples")
    func rollingWindow() {
        let r = FrameTimingRecorder(maxSamples: 10)
        for i in 1...20 { r.record(Double(i)) }
        #expect(r.sampleCount == 10)
        #expect(r.p50Ms >= 15.0 && r.p50Ms <= 16.0)
        #expect(r.p95Ms >= 19.0 && r.p95Ms <= 20.0)
    }

    @Test("reset() clears state")
    func resetClears() {
        let r = FrameTimingRecorder()
        for i in 1...10 { r.record(Double(i)) }
        r.reset()
        #expect(r.sampleCount == 0)
        #expect(r.p50Ms == 0)
        #expect(r.p95Ms == 0)
    }

    @Test("Static percentile() handles empty array")
    func staticPercentileEmpty() {
        #expect(FrameTimingRecorder.percentile([], 0.5) == 0)
    }

    @Test("Static percentile() clamps to last element at p=1.0")
    func staticPercentileMax() {
        #expect(FrameTimingRecorder.percentile([1.0, 2.0, 3.0, 4.0, 5.0], 1.0) == 5.0)
    }
}

@Suite("IdentityFrameProcessor pass-through")
struct IdentityFrameProcessorTests {

    @Test("Returns the input buffer unmodified")
    func identity() {
        var pixelBuffer: CVPixelBuffer?
        let attrs: [CFString: Any] = [
            kCVPixelBufferIOSurfacePropertiesKey: [:] as [CFString: Any]
        ]
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault, 16, 16,
            kCVPixelFormatType_32BGRA,
            attrs as CFDictionary,
            &pixelBuffer
        )
        #expect(status == kCVReturnSuccess)
        guard let buffer = pixelBuffer else { return }

        let processor = IdentityFrameProcessor()
        let result = processor.process(buffer)
        #expect(result === buffer)
    }
}
