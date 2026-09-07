import SwiftUI

// ──────────────────────────────────────────────────────────────────
// TopicDetailView — full content for one interview topic
// Tabs: Overview | Code | Quiz
// ──────────────────────────────────────────────────────────────────
struct TopicDetailView: View {
    let topic: InterviewTopic
    @EnvironmentObject private var progressStore: ProgressStore
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            topicHeader
            tabPicker
            Divider()
            tabContent
        }
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    progressStore.toggleTopic(id: topic.id)
                } label: {
                    Image(systemName: progressStore.isTopicCompleted(topic.id)
                          ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(topic.color)
                }
            }
        }
    }

    // MARK: - Header

    private var topicHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(topic.color.opacity(0.12)).frame(width: 44, height: 44)
                Image(systemName: topic.icon).foregroundStyle(topic.color).font(.title3)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(topic.title).font(.headline)
                HStack(spacing: 4) {
                    Image(systemName: topic.difficulty.icon).font(.caption2).foregroundStyle(topic.difficulty.color)
                    Text(topic.difficulty.rawValue).font(.caption).foregroundStyle(topic.difficulty.color)
                }
            }
            Spacer()
        }
        .padding(.horizontal).padding(.vertical, 10)
        .background(topic.color.opacity(0.06))
    }

    // MARK: - Tab Picker

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(Array(["Overview", "Code", "Quiz"].enumerated()), id: \.offset) { idx, title in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = idx }
                } label: {
                    VStack(spacing: 4) {
                        Text(title)
                            .font(.subheadline)
                            .foregroundStyle(selectedTab == idx ? topic.color : .secondary)
                            .padding(.vertical, 10)
                        Rectangle().frame(height: 2)
                            .foregroundStyle(selectedTab == idx ? topic.color : .clear)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0: overviewTab
        case 1: codeTab
        case 2: QuizView(questions: topic.quiz, topicID: topic.id, accentColor: topic.color)
        default: EmptyView()
        }
    }

    private var overviewTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Overview
                Text(topic.overview)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .padding(.bottom, 4)

                // Key Concepts
                VStack(alignment: .leading, spacing: 12) {
                    Label("Key Concepts", systemImage: "key.fill")
                        .font(.headline)
                    ForEach(topic.keyConcepts) { concept in
                        ConceptRow(concept: concept, color: topic.color)
                    }
                }
            }
            .padding()
        }
    }

    private var codeTab: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(topic.codeSnippets) { snippet in
                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(snippet.title).font(.headline)
                            Text(snippet.description).font(.caption).foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)

                        CodeViewerView(
                            code: snippet.code,
                            filename: snippet.title,
                            layerColor: topic.color
                        )
                        .frame(minHeight: 200)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Concept Row

private struct ConceptRow: View {
    let concept: KeyConcept
    let color: Color
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack {
                    Text(concept.term)
                        .font(.subheadline.bold())
                        .foregroundStyle(color)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if isExpanded {
                Text(concept.explanation)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(12)
        .background(color.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NavigationStack {
        TopicDetailView(topic: InterviewTopicsLibrary.memoryManagement)
    }
    .environmentObject(ProgressStore())
}
