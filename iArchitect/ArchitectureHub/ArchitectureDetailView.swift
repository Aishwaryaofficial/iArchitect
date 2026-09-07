import SwiftUI

// ──────────────────────────────────────────────────────────────────
// ArchitectureDetailView — tabbed detail for a single pattern
// Tabs: Live Demo | Code | Diagram | Concepts
// ──────────────────────────────────────────────────────────────────
struct ArchitectureDetailView: View {
    let pattern: ArchPattern
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            patternHeader
            tabPicker
            Divider()
            tabContent
        }
        .navigationTitle(pattern.acronym)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    progressStore.togglePattern(id: pattern.id)
                } label: {
                    Image(systemName: progressStore.isPatternCompleted(pattern.id)
                          ? "bookmark.fill" : "bookmark")
                    .foregroundStyle(pattern.color)
                }
            }
        }
    }

    // MARK: - Header

    private var patternHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: pattern.icon)
                .font(.title)
                .foregroundStyle(pattern.color)
            VStack(alignment: .leading, spacing: 2) {
                Text(pattern.name)
                    .font(.headline)
                Text(pattern.tagline)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(pattern.color.opacity(0.06))
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { idx, tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = idx
                        }
                    } label: {
                        VStack(spacing: 4) {
                            HStack(spacing: 4) {
                                Image(systemName: tab.icon).font(.caption)
                                Text(tab.title).font(.subheadline)
                            }
                            .foregroundStyle(selectedTab == idx ? pattern.color : .secondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)

                            Rectangle()
                                .frame(height: 2)
                                .foregroundStyle(selectedTab == idx ? pattern.color : .clear)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }

    private let tabs = [
        (title: "Demo",      icon: "play.circle.fill"),
        (title: "Code",      icon: "doc.text.fill"),
        (title: "Diagram",   icon: "arrow.triangle.branch"),
        (title: "Concepts",  icon: "lightbulb.fill"),
    ]

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0: demoTab
        case 1: codeTab
        case 2: diagramTab
        case 3: conceptsTab
        default: EmptyView()
        }
    }

    @ViewBuilder
    private var demoTab: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Live Demo").font(.caption.bold()).foregroundStyle(.secondary)
                Spacer()
                Text("Interact with the \(pattern.acronym) implementation below")
                    .font(.caption).foregroundStyle(.secondary)
            }
            .padding(.horizontal).padding(.top, 8)

            Divider().padding(.top, 4)

            switch pattern.id {
            case "mvc":   MVCDemoView()
            case "mvp":   MVPDemoView()
            case "mvvm":  MVVMDemoView()
            case "viper": VIPERDemoView()
            case "clean": CleanDemoView()
            case "tca":   TCADemoView()
            default:      Text("Demo not available").foregroundStyle(.secondary)
            }
        }
    }

    private var codeTab: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                TabbedCodeViewer(files: pattern.files)
                    .frame(minHeight: 500)
            }
            .padding()
        }
    }

    private var diagramTab: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Data Flow Diagram").font(.caption.bold()).foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal).padding(.top, 8)
            Divider().padding(.top, 4)
            DiagramView(pattern: pattern)
        }
    }

    private var conceptsTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Layers
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "Layers", icon: "square.stack.3d.up")
                    ForEach(pattern.layers) { layer in
                        LayerRow(layer: layer)
                    }
                }

                // Key principles
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Key Principles", icon: "lightbulb")
                    ForEach(pattern.keyPrinciples, id: \.self) { principle in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(pattern.color)
                                .font(.caption)
                                .padding(.top, 2)
                            Text(principle).font(.subheadline)
                        }
                    }
                }

                // Pros
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Advantages", icon: "hand.thumbsup")
                    ForEach(pattern.pros, id: \.self) { pro in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "plus.circle.fill").foregroundStyle(.green).font(.caption).padding(.top, 2)
                            Text(pro).font(.subheadline)
                        }
                    }
                }

                // Cons
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Disadvantages", icon: "hand.thumbsdown")
                    ForEach(pattern.cons, id: \.self) { con in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "minus.circle.fill").foregroundStyle(.orange).font(.caption).padding(.top, 2)
                            Text(con).font(.subheadline)
                        }
                    }
                }

                // Use Cases
                VStack(alignment: .leading, spacing: 8) {
                    SectionHeader(title: "Best For", icon: "target")
                    ForEach(pattern.useCases, id: \.self) { useCase in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "arrow.right.circle.fill").foregroundStyle(.blue).font(.caption).padding(.top, 2)
                            Text(useCase).font(.subheadline)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Helper Sub-views

private struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.subheadline)
            Text(title).font(.headline)
        }
        .padding(.bottom, 2)
    }
}

private struct LayerRow: View {
    let layer: PatternLayer

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 4)
                .fill(layer.color)
                .frame(width: 4, height: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(layer.name).font(.subheadline.bold()).foregroundStyle(layer.color)
                Text(layer.role).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        ArchitectureDetailView(pattern: ArchitectureLibrary.mvvm)
    }
    .environmentObject(ProgressStore())
}
