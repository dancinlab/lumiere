import SwiftUI

/// Studio tab — top-level switcher between three post-capture creative
/// surfaces:
///   • Direct  (DIRECTS verb / hexa-main-character) — current content
///   • Edit    (EDITS verb / hexa-vsco)             — Atelier editor
///   • Author  (AUTHORS verb / hexa-filter-algebra) — Forge authoring
///
/// Per the mk2-D absorption (commit 239b9f8), the EDITS + AUTHORS verbs
/// fold into the Studio tab as sub-surfaces rather than separate tabs.
struct StudioView: View {
    @State private var surface: StudioSurface = .direct

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Surface", selection: $surface) {
                    ForEach(StudioSurface.allCases) { s in
                        Text(s.label).tag(s)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                switch surface {
                case .direct: DirectStudioView()
                case .edit:   AtelierView()
                case .author: ForgeView()
                }
            }
            .navigationTitle("Lumière Studio")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

enum StudioSurface: String, CaseIterable, Identifiable {
    case direct, edit, author

    var id: String { rawValue }

    var label: String {
        switch self {
        case .direct: return "Direct"
        case .edit:   return "Edit"
        case .author: return "Author"
        }
    }

    var verb: String {
        switch self {
        case .direct: return "DIRECTS"
        case .edit:   return "EDITS"
        case .author: return "AUTHORS"
        }
    }
}
