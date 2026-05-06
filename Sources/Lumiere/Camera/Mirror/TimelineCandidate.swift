import Foundation
import UIKit

/// A single slot in the Mirror 8-grid. mk3-C ships the value type with
/// thumbnail-optional storage; the actual InstantID-anchored render
/// lands at `parallel_self.cond.2` (mk4) when the SD v3 + LoRA pipeline
/// produces real bitmaps to back `thumbnail`.
struct TimelineCandidate: Identifiable, Hashable, Sendable {
    let id: UUID
    let axis: IdentityAxis
    let label: String

    /// `Sendable`-compatible thumbnail handle. mk3-C populates this lazily
    /// or leaves it nil; the view falls back to a glyph placeholder.
    /// `UIImage` is documented as thread-safe to read after construction,
    /// which is how `parallel_self.cond.2` will produce instances at mk4.
    let thumbnail: UIImage?

    init(axis: IdentityAxis, label: String, thumbnail: UIImage? = nil, id: UUID = UUID()) {
        self.id = id
        self.axis = axis
        self.label = label
        self.thumbnail = thumbnail
    }

    static func == (lhs: TimelineCandidate, rhs: TimelineCandidate) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
