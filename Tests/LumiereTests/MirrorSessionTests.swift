import Testing
import Foundation
@testable import Lumiere

@Suite("MirrorSession + IdentityAxis + TimelineCandidate")
@MainActor
struct MirrorSessionTests {

    @Test("generate produces exactly 8 candidates")
    func eightCandidates() async {
        let session = MirrorSession()
        await session.generate()
        #expect(session.generatedTimelines.count == 8)
    }

    @Test("default 8-grid honours mk3 axis split (5 era + 3 culture)")
    func mk3AxisSplit() {
        let entries = IdentityAxisBank.defaultEightGrid()
        let era = entries.filter { $0.axis == .era }.count
        let culture = entries.filter { $0.axis == .culture }.count
        #expect(era == 5)
        #expect(culture == 3)
    }

    @Test("era axis bank has at least 5 entries")
    func eraAxisBank() {
        let entries = IdentityAxisBank.entries(for: .era)
        #expect(entries.count >= 5)
    }

    @Test("IdentityAxis cases match the 5 declared in spec")
    func fiveAxes() {
        #expect(IdentityAxis.allCases.count == 5)
        #expect(IdentityAxis.allCases.contains(.era))
        #expect(IdentityAxis.allCases.contains(.culture))
        #expect(IdentityAxis.allCases.contains(.profession))
        #expect(IdentityAxis.allCases.contains(.aesthetic))
        #expect(IdentityAxis.allCases.contains(.personal))
    }

    @Test("generate completes within 100 ms (loose bound; spec p95 = 18 ms is device-only)")
    func generateFast() async {
        let session = MirrorSession()
        let start = Date()
        await session.generate()
        let elapsed = Date().timeIntervalSince(start)
        #expect(elapsed < 0.1)
        #expect(session.lastGenerationMs > 0)
    }

    @Test("reset clears generated timelines + isGenerating + lastGenerationMs")
    func resetClears() async {
        let session = MirrorSession()
        await session.generate()
        #expect(!session.generatedTimelines.isEmpty)
        session.reset()
        #expect(session.generatedTimelines.isEmpty)
        #expect(session.isGenerating == false)
        #expect(session.lastGenerationMs == 0)
    }

    @Test("TimelineCandidate IDs are unique across the default grid")
    func uniqueCandidateIDs() {
        let entries = IdentityAxisBank.defaultEightGrid()
        let ids = Set(entries.map(\.id))
        #expect(ids.count == entries.count)
    }
}
