import SwiftUI

// ──────────────────────────────────────────────────────────────────
// ProgressView — overview of learning progress
// ──────────────────────────────────────────────────────────────────
struct LearningProgressView: View {
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var showResetAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                overallProgressCard
                patternsSection
                topicsSection
                quizScoresSection
                resetButton
            }
            .padding()
        }
        .navigationTitle("My Progress")
        .navigationBarTitleDisplayMode(.large)
        .alert("Reset Progress", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) { progressStore.resetAll() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will erase all your progress, bookmarks, and quiz scores.")
        }
    }

    // MARK: - Sub-views

    private var overallProgressCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Overall Progress")
                    .font(.headline)
                Spacer()
                Text("\(Int(progressStore.totalProgress * 100))%")
                    .font(.title2.bold())
                    .foregroundStyle(.blue)
            }

            SwiftUI.ProgressView(value: progressStore.totalProgress)
                .tint(.blue)
                .scaleEffect(y: 3)

            HStack(spacing: 20) {
                statPill(value: progressStore.completedPatterns.count,
                         total: ArchitectureLibrary.all.count,
                         label: "Patterns", color: .purple)
                statPill(value: progressStore.completedTopics.count,
                         total: InterviewTopicsLibrary.all.count,
                         label: "Topics", color: .orange)
                statPill(value: progressStore.quizScores.count,
                         total: InterviewTopicsLibrary.all.count,
                         label: "Quizzes", color: .green)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Architecture Patterns", systemImage: "rectangle.3.group.fill")
                .font(.headline)

            ForEach(ArchitectureLibrary.all) { pattern in
                HStack(spacing: 12) {
                    Image(systemName: pattern.icon)
                        .foregroundStyle(pattern.color)
                        .frame(width: 24)
                    Text(pattern.name)
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: progressStore.isPatternCompleted(pattern.id)
                          ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(progressStore.isPatternCompleted(pattern.id) ? .green : Color(.systemGray4))
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var topicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Interview Topics", systemImage: "brain.head.profile")
                .font(.headline)

            ForEach(InterviewTopicsLibrary.all) { topic in
                HStack(spacing: 12) {
                    Image(systemName: topic.icon)
                        .foregroundStyle(topic.color)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(topic.title).font(.subheadline)
                        if let score = progressStore.quizScores[topic.id] {
                            Text("Best quiz: \(score.bestScore)/\(score.total)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    Image(systemName: progressStore.isTopicCompleted(topic.id)
                          ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(progressStore.isTopicCompleted(topic.id) ? .green : Color(.systemGray4))
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @ViewBuilder
    private var quizScoresSection: some View {
        if !progressStore.quizScores.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Label("Quiz Scores", systemImage: "chart.bar.fill")
                    .font(.headline)

                ForEach(progressStore.quizScores.values.sorted(by: { $0.topicID < $1.topicID }), id: \.topicID) { score in
                    let topic = InterviewTopicsLibrary.all.first { $0.id == score.topicID }
                    HStack(spacing: 10) {
                        if let t = topic {
                            Image(systemName: t.icon).foregroundStyle(t.color).frame(width: 20)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(topic?.title ?? score.topicID).font(.subheadline)
                            Text("\(score.attempts) attempt\(score.attempts == 1 ? "" : "s")")
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(score.bestScore)/\(score.total)")
                                .font(.subheadline.bold())
                                .foregroundStyle(scoreColor(score.percentage))
                            Text("best").font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var resetButton: some View {
        Button(role: .destructive) {
            showResetAlert = true
        } label: {
            Label("Reset All Progress", systemImage: "trash")
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.08))
                .foregroundStyle(.red)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Helpers

    private func statPill(value: Int, total: Int, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(value)/\(total)").font(.title3.bold()).foregroundStyle(color)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func scoreColor(_ pct: Double) -> Color {
        pct >= 1.0 ? .green : pct >= 0.67 ? .orange : .red
    }
}

#Preview {
    NavigationStack {
        LearningProgressView()
    }
    .environmentObject(ProgressStore())
}
