import Foundation

/// Fixed default 8-grid the spec-mk3 phase ships. Each entry tags the
/// `IdentityAxis` so downstream UI (or mk4 LoRA selection) can route
/// across axes. mk3 covers `era` (5 entries) + `culture` (3 entries) =
/// 8 total — matching the slot-machine grid count without overflowing.
enum IdentityAxisBank {

    /// Returns 8 fresh `TimelineCandidate` instances (new UUIDs each
    /// call) — appropriate for `MirrorSession.generate(from:)`'s
    /// per-capture batch.
    static func defaultEightGrid() -> [TimelineCandidate] {
        return [
            TimelineCandidate(axis: .era,     label: "Renaissance"),
            TimelineCandidate(axis: .era,     label: "Edo"),
            TimelineCandidate(axis: .era,     label: "Belle Époque"),
            TimelineCandidate(axis: .era,     label: "1980s"),
            TimelineCandidate(axis: .era,     label: "2070s"),
            TimelineCandidate(axis: .culture, label: "Cottagecore"),
            TimelineCandidate(axis: .culture, label: "Cyberpunk"),
            TimelineCandidate(axis: .culture, label: "Y2K")
        ]
    }

    /// Pre-bucketed view of the default grid by axis, useful for
    /// `MirrorView` filter rows or roadmap cond.3 verification tests.
    static func entries(for axis: IdentityAxis) -> [TimelineCandidate] {
        defaultEightGrid().filter { $0.axis == axis }
    }
}
