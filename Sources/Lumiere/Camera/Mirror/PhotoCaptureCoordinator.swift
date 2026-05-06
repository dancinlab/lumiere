@preconcurrency import AVFoundation
import CoreVideo
import Foundation

/// Bridges `AVCapturePhotoOutput`'s Objective-C delegate callback into
/// a Swift `async` `capturePhoto()` API. mk4-C closure: Mirror's
/// "Capture" button now drives a real `AVCapturePhotoSettings` round-
/// trip instead of just sleeping 18 ms.
///
/// The photo is delivered as a CVPixelBuffer suitable for the eventual
/// SD v3 + InstantID inference pipeline (`parallel_self.cond.2`, mk5).
/// mk4-C surfaces the buffer to the UI layer; the LoRA-driven 8-grid
/// generation is still stubbed via `MirrorSession`'s placeholder timing
/// path until weight conversion lands.
final class PhotoCaptureCoordinator: NSObject, AVCapturePhotoCaptureDelegate, @unchecked Sendable {
    private var continuation: CheckedContinuation<CVPixelBuffer, Error>?

    func capturePhoto(from output: AVCapturePhotoOutput) async throws -> CVPixelBuffer {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<CVPixelBuffer, Error>) in
            self.continuation = cont
            let settings = AVCapturePhotoSettings()
            settings.photoQualityPrioritization = .balanced
            output.capturePhoto(with: settings, delegate: self)
        }
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        defer { self.continuation = nil }

        if let error {
            self.continuation?.resume(throwing: error)
            return
        }

        guard let pixelBuffer = photo.pixelBuffer else {
            self.continuation?.resume(
                throwing: PhotoCaptureError.noPixelBuffer
            )
            return
        }
        self.continuation?.resume(returning: pixelBuffer)
    }

    enum PhotoCaptureError: Error {
        case noPixelBuffer
    }
}
