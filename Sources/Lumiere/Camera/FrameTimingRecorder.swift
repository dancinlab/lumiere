import Foundation
import Combine

/// Rolling-window p50 / p95 latency recorder for the camera frame
/// pipeline. Default 600-sample window = 10 s at 60 fps, the time scale
/// at which the F-CFA-MVP-1 falsifier's "p95 ≤ 25 ms on iPhone 15 Pro"
/// threshold is meant to be evaluated.
@MainActor
final class FrameTimingRecorder: ObservableObject {
    @Published private(set) var p50Ms: Double = 0
    @Published private(set) var p95Ms: Double = 0
    @Published private(set) var sampleCount: Int = 0

    private var samples: [Double] = []
    private let maxSamples: Int

    init(maxSamples: Int = 600) {
        self.maxSamples = max(1, maxSamples)
    }

    func record(_ ms: Double) {
        if samples.count >= maxSamples { samples.removeFirst() }
        samples.append(ms)
        recompute()
    }

    func reset() {
        samples.removeAll()
        p50Ms = 0
        p95Ms = 0
        sampleCount = 0
    }

    private func recompute() {
        sampleCount = samples.count
        guard !samples.isEmpty else { return }
        let sorted = samples.sorted()
        p50Ms = Self.percentile(sorted, 0.50)
        p95Ms = Self.percentile(sorted, 0.95)
    }

    static func percentile(_ sorted: [Double], _ p: Double) -> Double {
        guard !sorted.isEmpty else { return 0 }
        let pos = Double(sorted.count - 1) * p
        let idx = max(0, min(sorted.count - 1, Int(pos)))
        return sorted[idx]
    }
}
