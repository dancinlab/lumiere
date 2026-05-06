@preconcurrency import AVFoundation
import CoreVideo
import QuartzCore

/// Bridges `AVCaptureVideoDataOutputSampleBufferDelegate` (Objective-C
/// callback on a background queue) to the Swift-native `FrameProcessor`
/// + timing-recorder pipeline. Measures wall-clock processing latency
/// per frame using `CACurrentMediaTime()` (mach-time, monotonic).
final class CameraSampleBufferDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    private let processor: FrameProcessor
    private let timingHandler: (Double) -> Void

    init(processor: FrameProcessor, timingHandler: @escaping (Double) -> Void) {
        self.processor = processor
        self.timingHandler = timingHandler
        super.init()
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let start = CACurrentMediaTime()
        _ = processor.process(pixelBuffer)
        let elapsedMs = (CACurrentMediaTime() - start) * 1000.0
        timingHandler(elapsedMs)
    }
}
