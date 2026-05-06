import Testing
import Foundation
import CoreVideo
@testable import Lumiere

@Suite("Mirror photo-capture wire (mk4-C)")
@MainActor
struct MirrorPhotoCaptureTests {

    private func makePixelBuffer(width: Int, height: Int) -> CVPixelBuffer {
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

    @Test("generate(from:) records selfie dimensions when a buffer is supplied")
    func recordsDimensions() async {
        let session = MirrorSession()
        let buf = makePixelBuffer(width: 4032, height: 3024)
        await session.generate(from: buf)
        #expect(session.lastSelfieDimensions == CGSize(width: 4032, height: 3024))
    }

    @Test("generate() with nil buffer records nil dimensions (stub-fallback path)")
    func nilDimensionsWhenNoBuffer() async {
        let session = MirrorSession()
        await session.generate()
        #expect(session.lastSelfieDimensions == nil)
    }

    @Test("reset clears lastSelfieDimensions alongside other state")
    func resetClearsDimensions() async {
        let session = MirrorSession()
        let buf = makePixelBuffer(width: 1024, height: 768)
        await session.generate(from: buf)
        #expect(session.lastSelfieDimensions != nil)
        session.reset()
        #expect(session.lastSelfieDimensions == nil)
        #expect(session.generatedTimelines.isEmpty)
    }

    @Test("PhotoCaptureCoordinator init is non-throwing and reusable")
    func coordinatorInit() {
        let c1 = PhotoCaptureCoordinator()
        let c2 = PhotoCaptureCoordinator()
        #expect(c1 !== c2)
    }
}
