import SwiftUI
import CoreImage

/// hexa-vsco surface — EDITS · LIBRARY · DISCOVER verb.
/// mk3-C ships the structural runtime (50-inaugural library,
/// RecipeShareCodec, PhysicsTool catalog). mk4-B closes the
/// cross-domain wire: tapping a LibraryFilter renders its Forge
/// Recipe through the FilterAlgebra runtime against a sample
/// gradient and shows the result in a before/after preview.
/// Full editor (HSL panel / tone curve UI / Studio / Discover /
/// Free vs Pro) lands at vsco.cond.2 (mk5).
struct AtelierView: View {
    @StateObject private var library = AtelierLibrary()
    private let physicsTools: [PhysicsTool] = PhysicsTool.allCases

    @State private var selectedFilter: LibraryFilter?

    private let demoRecipe = "color_matrix ∘ vignette(0.3) ∘ grain(0.2)"

    var body: some View {
        List {
            librarySection
            previewSection
            physicsToolsSection
            recipeShareSection
            futureSection
        }
        .sheet(item: $selectedFilter) { filter in
            FilterPreviewSheet(filter: filter)
        }
    }

    // MARK: - Sections

    private var librarySection: some View {
        Section {
            ForEach(library.filters.prefix(10)) { f in
                Button {
                    selectedFilter = f
                } label: {
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .frame(width: 28)
                            .foregroundStyle(.tint)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(f.name)
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text(f.recipe)
                                .font(.caption2.monospaced())
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                            .font(.caption)
                    }
                }
            }
            HStack {
                Text("\(library.count) total inaugural filters")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.tertiary)
                Spacer()
                Text("F-VSCO-MVP-2 ✓")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.green)
            }
        } header: {
            Text("Library — first 10 of \(library.count)")
        } footer: {
            Text("vsco.cond.3 met · tap a filter to render through the Forge runtime")
                .font(.caption2.monospaced())
        }
    }

    private var previewSection: some View {
        Section {
            HStack(spacing: 16) {
                VStack(spacing: 6) {
                    Text("Source")
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                    sampleSwatch
                }
                Image(systemName: "arrow.right")
                    .foregroundStyle(.tertiary)
                VStack(spacing: 6) {
                    Text("Filtered")
                        .font(.caption2.monospaced())
                        .foregroundStyle(.secondary)
                    filteredSwatch(recipe: demoRecipe)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        } header: {
            Text("Forge runtime preview · \(demoRecipe)")
        } footer: {
            Text("vsco.cond.2 (cross-wire) — RecipeParser → FilterComposition → CIContext")
                .font(.caption2.monospaced())
        }
    }

    private var physicsToolsSection: some View {
        Section {
            ForEach(physicsTools) { tool in
                HStack {
                    Image(systemName: tool.symbol)
                        .frame(width: 28)
                        .foregroundStyle(.tint)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tool.displayName).font(.body)
                        Text(tool.anchor)
                            .font(.caption2.monospaced())
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("mk5").font(.caption2.monospaced()).foregroundStyle(.tertiary)
                }
                .opacity(0.7)
            }
        } header: {
            Text("7 physics tools (mk5 kernel impls)")
        } footer: {
            Text("vsco.cond.5 — CIFilter/Metal kernel lands at mk5")
                .font(.caption2.monospaced())
        }
    }

    private var recipeShareSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Text("Input recipe")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                Text(demoRecipe).font(.body.monospaced())
                Text("RecipeShareCodec.encode →")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                Text(RecipeShareCodec.encode(demoRecipe).absoluteString)
                    .font(.caption.monospaced())
                    .foregroundStyle(.tint)
                    .lineLimit(2)
                    .truncationMode(.middle)
                Text("→ decode roundtrip")
                    .font(.caption2.monospaced())
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                Text(roundTripped).font(.body.monospaced()).foregroundStyle(.green)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Recipe URL share-load (mk3-C runtime)")
        } footer: {
            Text("vsco.cond.4 + F-VSCO-MVP-3 — codec ships, 1000-tx reliability is mk5")
                .font(.caption2.monospaced())
        }
    }

    private var futureSection: some View {
        Section {
            placeholderRow(
                icon: "person.2",
                title: "Discover",
                subtitle: "70% creator royalty marketplace · vsco.cond.6 · mk6"
            )
            placeholderRow(
                icon: "creditcard",
                title: "Free vs Pro tier gate",
                subtitle: "vsco.cond.2 · mk5"
            )
        } header: {
            Text("Studio · Discover · Tiers (mk5+)")
        }
    }

    // MARK: - Helpers

    private var sampleSwatch: some View {
        renderUIImage(AtelierPreviewRenderer.defaultSample())
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 90, height: 90)
            .clipShape(.rect(cornerRadius: 8))
    }

    private func filteredSwatch(recipe: String) -> some View {
        Group {
            switch AtelierPreviewRenderer.render(
                recipe: recipe,
                sample: AtelierPreviewRenderer.defaultSample()
            ) {
            case .success(let img):
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                Image(systemName: "exclamationmark.triangle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.red)
            }
        }
        .frame(width: 90, height: 90)
        .clipShape(.rect(cornerRadius: 8))
    }

    private func renderUIImage(_ ci: CIImage) -> Image {
        let context = CIContext(options: [.cacheIntermediates: false])
        if let cg = context.createCGImage(ci, from: ci.extent) {
            return Image(uiImage: UIImage(cgImage: cg))
        }
        return Image(systemName: "photo")
    }

    private var roundTripped: String {
        let url = RecipeShareCodec.encode(demoRecipe)
        switch RecipeShareCodec.decode(url) {
        case .success(let s): return s
        case .failure(let e): return "decode error: \(e)"
        }
    }

    private func placeholderRow(icon: String, title: String, subtitle: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 28)
                .foregroundStyle(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body)
                Text(subtitle).font(.caption2.monospaced()).foregroundStyle(.secondary)
            }
            Spacer()
            Text("mk5").font(.caption2.monospaced()).foregroundStyle(.tertiary)
        }
        .opacity(0.7)
    }
}

private struct FilterPreviewSheet: View {
    let filter: LibraryFilter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        VStack(spacing: 6) {
                            Text("Source").font(.caption2.monospaced()).foregroundStyle(.secondary)
                            renderSource()
                        }
                        Image(systemName: "arrow.right").foregroundStyle(.tertiary)
                        VStack(spacing: 6) {
                            Text("Filtered").font(.caption2.monospaced()).foregroundStyle(.secondary)
                            renderFiltered()
                        }
                    }
                    .padding()

                    GroupBox(label: Label("Recipe", systemImage: "doc.plaintext")) {
                        Text(filter.recipe)
                            .font(.body.monospaced())
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)

                    GroupBox(label: Label("Share URL", systemImage: "link")) {
                        Text(RecipeShareCodec.encode(filter.recipe).absoluteString)
                            .font(.caption.monospaced())
                            .foregroundStyle(.tint)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .padding(.horizontal)

                    Text("Forge runtime · cross-domain wire (mk4-B)")
                        .font(.caption2.monospaced())
                        .foregroundStyle(.tertiary)
                        .padding(.bottom, 16)
                }
            }
            .navigationTitle(filter.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func renderSource() -> some View {
        let context = CIContext(options: [.cacheIntermediates: false])
        let ci = AtelierPreviewRenderer.defaultSample(size: CGSize(width: 320, height: 320))
        if let cg = context.createCGImage(ci, from: ci.extent) {
            return AnyView(
                Image(uiImage: UIImage(cgImage: cg))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                    .clipShape(.rect(cornerRadius: 12))
            )
        }
        return AnyView(Image(systemName: "photo").frame(width: 140, height: 140))
    }

    private func renderFiltered() -> some View {
        switch AtelierPreviewRenderer.render(
            recipe: filter.recipe,
            sample: AtelierPreviewRenderer.defaultSample(size: CGSize(width: 320, height: 320))
        ) {
        case .success(let img):
            return AnyView(
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                    .clipShape(.rect(cornerRadius: 12))
            )
        case .failure:
            return AnyView(
                Image(systemName: "exclamationmark.triangle")
                    .frame(width: 140, height: 140)
                    .foregroundStyle(.red)
            )
        }
    }
}
