import Foundation
import Combine

// ──────────────────────────────────────────────────────────────────
// ProgressStore — tracks which patterns and topics the user has
// completed, and records quiz scores. Backed by UserDefaults via
// @AppStorage-compatible keys so state persists across app launches.
// ──────────────────────────────────────────────────────────────────
final class ProgressStore: ObservableObject {

    // MARK: - Completed patterns
    @Published private(set) var completedPatterns: Set<String> = [] {
        didSet { save(key: Keys.patterns, value: Array(completedPatterns)) }
    }

    // MARK: - Completed topics
    @Published private(set) var completedTopics: Set<String> = [] {
        didSet { save(key: Keys.topics, value: Array(completedTopics)) }
    }

    // MARK: - Quiz scores  [topicID: QuizScore]
    @Published private(set) var quizScores: [String: QuizScore] = [:] {
        didSet {
            if let data = try? JSONEncoder().encode(quizScores) {
                UserDefaults.standard.set(data, forKey: Keys.quizScores)
            }
        }
    }

    // MARK: - Init

    init() {
        completedPatterns = Set(load(key: Keys.patterns))
        completedTopics   = Set(load(key: Keys.topics))

        if let data = UserDefaults.standard.data(forKey: Keys.quizScores),
           let decoded = try? JSONDecoder().decode([String: QuizScore].self, from: data) {
            quizScores = decoded
        }
    }

    // MARK: - Pattern Actions

    func togglePattern(id: String) {
        if completedPatterns.contains(id) {
            completedPatterns.remove(id)
        } else {
            completedPatterns.insert(id)
        }
    }

    func isPatternCompleted(_ id: String) -> Bool {
        completedPatterns.contains(id)
    }

    // MARK: - Topic Actions

    func toggleTopic(id: String) {
        if completedTopics.contains(id) {
            completedTopics.remove(id)
        } else {
            completedTopics.insert(id)
        }
    }

    func isTopicCompleted(_ id: String) -> Bool {
        completedTopics.contains(id)
    }

    // MARK: - Quiz Score

    func recordQuizScore(topicID: String, score: Int, total: Int) {
        let existing = quizScores[topicID]
        let newBest  = max(score, existing?.bestScore ?? 0)
        quizScores[topicID] = QuizScore(topicID: topicID,
                                         lastScore: score,
                                         bestScore: newBest,
                                         total: total,
                                         attempts: (existing?.attempts ?? 0) + 1)
        // Auto-complete topic if perfect score
        if score == total { completedTopics.insert(topicID) }
    }

    // MARK: - Reset

    func resetAll() {
        completedPatterns = []
        completedTopics   = []
        quizScores        = [:]
    }

    // MARK: - Computed Stats

    var totalProgress: Double {
        let total = ArchitectureLibrary.all.count + InterviewTopicsLibrary.all.count
        let done  = completedPatterns.count + completedTopics.count
        return total > 0 ? Double(done) / Double(total) : 0
    }

    // MARK: - Private

    private enum Keys {
        static let patterns   = "iArchitect.completedPatterns"
        static let topics     = "iArchitect.completedTopics"
        static let quizScores = "iArchitect.quizScores"
    }

    private func save(key: String, value: [String]) {
        UserDefaults.standard.set(value, forKey: key)
    }

    private func load(key: String) -> [String] {
        UserDefaults.standard.stringArray(forKey: key) ?? []
    }
}

// MARK: - Quiz Score Model

struct QuizScore: Codable, Equatable {
    let topicID: String
    let lastScore: Int
    let bestScore: Int
    let total: Int
    let attempts: Int

    var percentage: Double { Double(bestScore) / Double(total) }
}
