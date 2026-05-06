@preconcurrency import AVFoundation
import Combine

@MainActor
final class CameraSession: ObservableObject {
    let session = AVCaptureSession()
    let recorder = FrameTimingRecorder()

    /// Optional photo output — only attached when the caller passes
    /// `enablePhotoCapture: true` in the initializer. Mirror surface
    /// (mk4-C) uses it; the Filters APPLIES surface keeps it nil to
    /// avoid the extra session reconfiguration cost.
    private(set) var photoOutput: AVCapturePhotoOutput?

    @Published private(set) var isRunning = false
    @Published private(set) var permissionState: AVAuthorizationStatus

    private let processor: FrameProcessor
    private let enablePhotoCapture: Bool
    private lazy var bufferDelegate = CameraSampleBufferDelegate(
        processor: processor,
        timingHandler: { [weak self] ms in
            Task { @MainActor in self?.recorder.record(ms) }
        }
    )
    private let frameQueue = DispatchQueue(
        label: "com.need-singularity.lumiere.frames",
        qos: .userInitiated
    )

    init(
        processor: FrameProcessor = IdentityFrameProcessor(),
        enablePhotoCapture: Bool = false
    ) {
        self.processor = processor
        self.enablePhotoCapture = enablePhotoCapture
        permissionState = AVCaptureDevice.authorizationStatus(for: .video)
    }

    func requestPermissionAndStart() async {
        let current = AVCaptureDevice.authorizationStatus(for: .video)
        if current == .notDetermined {
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            permissionState = granted ? .authorized : .denied
        } else {
            permissionState = current
        }

        guard permissionState == .authorized else { return }
        configureAndStart()
    }

    func stop() {
        if session.isRunning { session.stopRunning() }
        isRunning = false
    }

    private func configureAndStart() {
        session.beginConfiguration()
        session.sessionPreset = .high

        if session.inputs.isEmpty,
           let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
           let input = try? AVCaptureDeviceInput(device: device),
           session.canAddInput(input) {
            session.addInput(input)
        }

        if !session.outputs.contains(where: { $0 is AVCaptureVideoDataOutput }) {
            let output = AVCaptureVideoDataOutput()
            output.alwaysDiscardsLateVideoFrames = true
            output.setSampleBufferDelegate(bufferDelegate, queue: frameQueue)
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
        }

        if enablePhotoCapture, photoOutput == nil {
            let photo = AVCapturePhotoOutput()
            if session.canAddOutput(photo) {
                session.addOutput(photo)
                self.photoOutput = photo
            }
        }

        session.commitConfiguration()
        session.startRunning()
        isRunning = true
    }
}
