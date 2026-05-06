import Foundation

/// Identity axis decomposition for `hexa-parallel-self` slot-machine
/// 8-grid generation. Spec §10 ARCHITECTURE distinguishes 5 axes
/// across which the InstantID-anchored selfie can be projected:
///
///   • era         — historical period rendering (Renaissance / Edo / …)
///   • culture     — aesthetic culture vector (Cottagecore / Cyberpunk / …)
///   • profession  — costume / role overlay (mk3 phase, deferred to mk4)
///   • aesthetic   — pure-aesthetic LoRA (mk4 — see .roadmap.parallel_self
///                   cond.3 phase plan)
///   • personal    — user-curated multiverse anchor (mk4)
///
/// mk3-C ships only `era` + `culture` per the spec's mk3 phase plan
/// (`.roadmap.parallel_self` cond.3). The remaining axes appear in the
/// enum for forward-compatibility with the `TimelineCandidate.axis`
/// tagging — they just have no live entries in `IdentityAxisBank`.
enum IdentityAxis: String, CaseIterable, Sendable, Codable {
    case era
    case culture
    case profession
    case aesthetic
    case personal
}
