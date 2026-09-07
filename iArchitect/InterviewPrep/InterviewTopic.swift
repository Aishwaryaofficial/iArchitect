import SwiftUI

// ──────────────────────────────────────────────────────────────────
// Interview Prep Data Models
// ──────────────────────────────────────────────────────────────────

struct InterviewTopic: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let difficulty: Difficulty
    let overview: String
    let keyConcepts: [KeyConcept]
    let codeSnippets: [CodeSnippet]
    let quiz: [QuizQuestion]
}

struct KeyConcept: Identifiable {
    let id = UUID()
    let term: String
    let explanation: String
}

struct CodeSnippet: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let code: String
    let language: String
}

struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

enum Difficulty: String, CaseIterable {
    case beginner     = "Beginner"
    case intermediate = "Intermediate"
    case advanced     = "Advanced"

    var color: Color {
        switch self {
        case .beginner:     return .green
        case .intermediate: return .orange
        case .advanced:     return .red
        }
    }

    var icon: String {
        switch self {
        case .beginner:     return "star"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced:     return "star.fill"
        }
    }
}
