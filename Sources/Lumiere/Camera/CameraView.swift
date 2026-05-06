import SwiftUI

/// Camera tab — top-level switcher between two capture surfaces:
///   • Filters (APPLIES verb / camera-filter-app)
///   • Mirror  (GENERATES verb / hexa-parallel-self)
///
/// Both share the live AVCaptureSession but invoke different
/// `FrameProcessor`s + post-capture treatments. Per the mk2-D
/// absorption (commit 239b9f8), the GENERATES verb folds into the
/// Camera tab as a sub-mode rather than a separate tab.
struct CameraView: View {
    @State private var surface: CameraSurface = .filters

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                switch surface {
                case .filters: FiltersCaptureView()
                case .mirror:  MirrorView()
                }
            }
            .ignoresSafeArea()

            surfacePicker
                .padding(.horizontal, 16)
                .padding(.top, 8)
        }
    }

    private var surfacePicker: some View {
        Picker("Surface", selection: $surface) {
            ForEach(CameraSurface.allCases) { s in
                Text(s.label).tag(s)
            }
        }
        .pickerStyle(.segmented)
        .background(.black.opacity(0.4), in: .rect(cornerRadius: 8))
    }
}

enum CameraSurface: String, CaseIterable, Identifiable {
    case filters, mirror

    var id: String { rawValue }

    var label: String {
        switch self {
        case .filters: return "Filters"
        case .mirror:  return "Mirror"
        }
    }

    var verb: String {
        switch self {
        case .filters: return "APPLIES"
        case .mirror:  return "GENERATES"
        }
    }
}
