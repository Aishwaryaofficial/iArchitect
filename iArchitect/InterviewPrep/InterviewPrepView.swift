import SwiftUI

// ──────────────────────────────────────────────────────────────────
// InterviewPrepView — browse all 10 interview topics
// ──────────────────────────────────────────────────────────────────
struct InterviewPrepView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var selectedDifficulty: Difficulty? = nil
    @State private var searchText = ""

    private var filteredTopics: [InterviewTopic] {
        var topics = InterviewTopicsLibrary.all
        if let diff = selectedDifficulty { topics = topics.filter { $0.difficulty == diff } }
        if !searchText.isEmpty {
            topics = topics.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.subtitle.localizedCaseInsensitiveContains(searchText)
            }
        }
        return topics
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                progressBanner
                difficultyFilter
                topicList
            }
            .padding()
        }
        .navigationTitle("Interview Prep")
        .navigationBarTitleDisplayMode(.large)
        .searchable(text: $searchText, prompt: "Search topics…")
    }

    // MARK: - Sub-views

    private var progressBanner: some View {
        let done = progressStore.completedTopics.count
        let total = InterviewTopicsLibrary.all.count
        let pct = total > 0 ? Double(done) / Double(total) : 0

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Your Progress")
                    .font(.headline)
                Spacer()
                Text("\(done)/\(total) topics")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            SwiftUI.ProgressView(value: pct)
                .tint(.green)
                .scaleEffect(y: 2)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var difficultyFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(label: "All", color: .secondary, isSelected: selectedDifficulty == nil) {
                    selectedDifficulty = nil
                }
                ForEach(Difficulty.allCases, id: \.rawValue) { diff in
                    FilterChip(label: diff.rawValue, color: diff.color,
                               isSelected: selectedDifficulty == diff) {
                        selectedDifficulty = selectedDifficulty == diff ? nil : diff
                    }
                }
            }
        }
    }

    private var topicList: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredTopics) { topic in
                NavigationLink(destination: TopicDetailView(topic: topic)) {
                    TopicCard(topic: topic)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Topic Card

struct TopicCard: View {
    let topic: InterviewTopic
    @EnvironmentObject private var progressStore: ProgressStore

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(topic.color.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: topic.icon)
                    .foregroundStyle(topic.color)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(topic.title).font(.headline)
                    Spacer()
                    if progressStore.isTopicCompleted(topic.id) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.subheadline)
                    }
                }
                Text(topic.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Image(systemName: topic.difficulty.icon)
                        .font(.caption2)
                        .foregroundStyle(topic.difficulty.color)
                    Text(topic.difficulty.rawValue)
                        .font(.caption2)
                        .foregroundStyle(topic.difficulty.color)
                    Text("•").foregroundStyle(.secondary).font(.caption2)
                    Text("\(topic.quiz.count) quiz questions")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(topic.color.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption.bold())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color.opacity(0.2) : Color(.systemGray5))
                .foregroundStyle(isSelected ? color : .secondary)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(isSelected ? color.opacity(0.4) : Color.clear, lineWidth: 1)
                )
        }
    }
}

#Preview {
    NavigationStack {
        InterviewPrepView()
    }
    .environmentObject(ProgressStore())
}
