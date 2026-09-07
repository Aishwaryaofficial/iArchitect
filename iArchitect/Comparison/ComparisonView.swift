import SwiftUI

// ──────────────────────────────────────────────────────────────────
// ComparisonView — side-by-side comparison of two architecture patterns
// ──────────────────────────────────────────────────────────────────
struct ComparisonView: View {
    @State private var leftPatternID  = "mvc"
    @State private var rightPatternID = "mvvm"
    @State private var selectedAspect = 0

    private var leftPattern:  ArchPattern { ArchitectureLibrary.all.first { $0.id == leftPatternID }  ?? ArchitectureLibrary.mvc }
    private var rightPattern: ArchPattern { ArchitectureLibrary.all.first { $0.id == rightPatternID } ?? ArchitectureLibrary.mvvm }

    private let aspects = ["Layers", "Pros & Cons", "Use Cases", "Code"]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                patternPickers
                aspectSelector
                comparisonContent
            }
            .padding()
        }
        .navigationTitle("Pattern Comparison")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sub-views

    private var headerSection: some View {
        Text("Select two patterns to compare them side by side.")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var patternPickers: some View {
        HStack(spacing: 12) {
            patternPicker(selectedID: $leftPatternID, excludeID: rightPatternID, label: "Pattern A")
            Image(systemName: "arrow.left.arrow.right")
                .foregroundStyle(.secondary)
            patternPicker(selectedID: $rightPatternID, excludeID: leftPatternID, label: "Pattern B")
        }
    }

    private func patternPicker(selectedID: Binding<String>, excludeID: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Menu {
                ForEach(ArchitectureLibrary.all.filter { $0.id != excludeID }) { pattern in
                    Button {
                        selectedID.wrappedValue = pattern.id
                    } label: {
                        Label(pattern.acronym, systemImage: pattern.icon)
                    }
                }
            } label: {
                let pattern = ArchitectureLibrary.all.first { $0.id == selectedID.wrappedValue }
                HStack {
                    if let p = pattern {
                        Image(systemName: p.icon).foregroundStyle(p.color)
                        Text(p.acronym).font(.headline).foregroundStyle(.primary)
                    }
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down").font(.caption).foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var aspectSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(aspects.enumerated()), id: \.offset) { idx, aspect in
                    Button {
                        withAnimation { selectedAspect = idx }
                    } label: {
                        Text(aspect)
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedAspect == idx
                                        ? Color.accentColor.opacity(0.15)
                                        : Color(.systemGray5))
                            .foregroundStyle(selectedAspect == idx ? Color.accentColor : Color.secondary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var comparisonContent: some View {
        switch selectedAspect {
        case 0: layerComparison
        case 1: prosConsComparison
        case 2: useCaseComparison
        case 3: codeComparison
        default: EmptyView()
        }
    }

    // MARK: - Layers comparison

    private var layerComparison: some View {
        HStack(alignment: .top, spacing: 12) {
            layerColumn(pattern: leftPattern)
            Divider()
            layerColumn(pattern: rightPattern)
        }
    }

    private func layerColumn(pattern: ArchPattern) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: pattern.icon).foregroundStyle(pattern.color)
                Text(pattern.acronym).font(.headline).foregroundStyle(pattern.color)
            }
            ForEach(pattern.layers) { layer in
                VStack(alignment: .leading, spacing: 3) {
                    Text(layer.name).font(.caption.bold()).foregroundStyle(layer.color)
                    Text(layer.role).font(.caption2).foregroundStyle(.secondary)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(layer.color.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Pros/Cons comparison

    private var prosConsComparison: some View {
        VStack(spacing: 16) {
            CompareRow(
                leftPattern: leftPattern,
                rightPattern: rightPattern,
                title: "Advantages",
                leftItems: leftPattern.pros,
                rightItems: rightPattern.pros,
                icon: "plus.circle.fill",
                color: .green
            )
            CompareRow(
                leftPattern: leftPattern,
                rightPattern: rightPattern,
                title: "Disadvantages",
                leftItems: leftPattern.cons,
                rightItems: rightPattern.cons,
                icon: "minus.circle.fill",
                color: .orange
            )
        }
    }

    // MARK: - Use Cases comparison

    private var useCaseComparison: some View {
        CompareRow(
            leftPattern: leftPattern,
            rightPattern: rightPattern,
            title: "Best For",
            leftItems: leftPattern.useCases,
            rightItems: rightPattern.useCases,
            icon: "target",
            color: .blue
        )
    }

    // MARK: - Code comparison

    private var codeComparison: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Show first code file of each pattern
            if let leftFile = leftPattern.files.first {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: leftPattern.icon).foregroundStyle(leftPattern.color)
                        Text(leftPattern.acronym + " — " + leftFile.filename)
                            .font(.caption.bold())
                            .foregroundStyle(leftPattern.color)
                    }
                    CodeViewerView(code: leftFile.code,
                                   filename: leftFile.filename,
                                   layerColor: leftPattern.color)
                    .frame(minHeight: 250)
                }
            }

            if let rightFile = rightPattern.files.first {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: rightPattern.icon).foregroundStyle(rightPattern.color)
                        Text(rightPattern.acronym + " — " + rightFile.filename)
                            .font(.caption.bold())
                            .foregroundStyle(rightPattern.color)
                    }
                    CodeViewerView(code: rightFile.code,
                                   filename: rightFile.filename,
                                   layerColor: rightPattern.color)
                    .frame(minHeight: 250)
                }
            }
        }
    }
}

// MARK: - Compare Row

private struct CompareRow: View {
    let leftPattern: ArchPattern
    let rightPattern: ArchPattern
    let title: String
    let leftItems: [String]
    let rightItems: [String]
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundStyle(color)

            HStack(alignment: .top, spacing: 12) {
                itemColumn(pattern: leftPattern, items: leftItems)
                Divider()
                itemColumn(pattern: rightPattern, items: rightItems)
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func itemColumn(pattern: ArchPattern, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(pattern.acronym)
                .font(.caption.bold())
                .foregroundStyle(pattern.color)
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                        .font(.caption2)
                        .padding(.top, 2)
                    Text(item).font(.caption).foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        ComparisonView()
    }
    .environmentObject(ProgressStore())
}
