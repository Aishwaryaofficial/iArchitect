import SwiftUI

// ──────────────────────────────────────────────────────────────────
// ArchitectureHubView — Home screen grid of all patterns
// ──────────────────────────────────────────────────────────────────
struct ArchitectureHubView: View {
    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                patternsGrid
                comparisonPromo
            }
            .padding()
        }
        .navigationTitle("Architectures")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sub-views

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("iOS Architecture Patterns")
                .font(.title2.bold())
            Text("The same Task Manager app — implemented in 6 different architecture patterns. Tap any card to see a live demo, source code, and diagram.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var patternsGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(ArchitectureLibrary.all) { pattern in
                NavigationLink(destination: ArchitectureDetailView(pattern: pattern)) {
                    PatternCard(pattern: pattern)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var comparisonPromo: some View {
        NavigationLink(destination: ComparisonView()) {
            HStack(spacing: 12) {
                Image(systemName: "arrow.left.arrow.right.square.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Compare Patterns")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("See two patterns side by side")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding()
            .background(
                LinearGradient(colors: [.blue, .purple],
                               startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pattern Card

struct PatternCard: View {
    let pattern: ArchPattern

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: pattern.icon)
                    .font(.title2)
                    .foregroundStyle(pattern.color)
                Spacer()
                Text(pattern.acronym)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(pattern.color.opacity(0.15))
                    .foregroundStyle(pattern.color)
                    .clipShape(Capsule())
            }

            Text(pattern.name)
                .font(.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Text(pattern.tagline)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Spacer(minLength: 0)

            // Layer chips
            HStack(spacing: 4) {
                ForEach(pattern.layers.prefix(3)) { layer in
                    Text(layer.name.prefix(1))  // first letter only
                        .font(.system(size: 9, weight: .bold))
                        .frame(width: 18, height: 18)
                        .background(layer.color.opacity(0.2))
                        .foregroundStyle(layer.color)
                        .clipShape(Circle())
                }
                if pattern.layers.count > 3 {
                    Text("+\(pattern.layers.count - 3)")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .frame(minHeight: 160)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(pattern.color.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        ArchitectureHubView()
    }
    .environmentObject(ProgressStore())
}
