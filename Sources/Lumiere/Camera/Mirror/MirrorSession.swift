import Foundation
import Combine
@preconcurrency import CoreVideo

/// `hexa-parallel-self` runtime session — single-tap slot-machine
/// generation. mk3-C ships the lifecycle shell + 18 ms p95 design-ceiling
/// timing (matches spec §19.2 F-PSELF-MVP-2 falsifier threshold) backed
/// by an `IdentityAxisBank.defaultEightGrid()` placeholder set.
///
/// The real SD v3 + InstantID cross-attention + LoRA-rank-≤-16 swap +
/// DDIM 4-step sampler loop lands at `parallel_self.cond.2` (mk4) once
/// the CLIP-Image / SD-v3 weights land via `scripts/convert_models.hexa`
/// (mk3-A clip_image branch already in place; SD-v3 conversion is mk4
/// scope).
@MainActor
final class MirrorSession: ObservableObject {
    @Published private(set) var generatedTimelines: [TimelineCandidate] = []
    @Published private(set) var isGenerating: Bool = false
    @Published private(set) var lastGenerationMs: Double = 0

    /// 18 ms p95 single-tap target per spec §10 hexa-parallel-self
    /// Block C: 4-step DDIM × 2.75 ms + decode 2 ms + overhead 5 ms.
    /// mk3-C uses this as a placeholder sleep so the UI surfaces the
    /// "InstantID is working" affordance without an actual model.
    private static let designCeilingNanos: UInt64 = 18_000_000

    /// mk3 stub — ignores the input pixel buffer and emits the
    /// `IdentityAxisBank` 8-grid after `designCeilingNanos`. Real
    /// pipeline is mk4 (`parallel_self.cond.2`).
    func generate(from selfie: CVPixelBuffer? = nil) async {
        let started = Date()
        isGenerating = true
        try? await Task.sleep(nanoseconds: Self.designCeilingNanos)
        generatedTimelines = IdentityAxisBank.defaultEightGrid()
        lastGenerationMs = Date().timeIntervalSince(started) * 1000
        isGenerating = false
    }

    func reset() {
        generatedTimelines = []
        isGenerating = false
        lastGenerationMs = 0
    }
}
