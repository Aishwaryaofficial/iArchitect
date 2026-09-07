import Foundation

// ─────────────────────────────────────────────────────────────────
// Clean Architecture – Domain Entity
// Lives in the Domain layer. Zero framework dependencies.
// This is the innermost circle in the Clean Architecture diagram.
// ─────────────────────────────────────────────────────────────────
struct CleanTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

// Domain errors — no external dependencies
enum CleanTaskError: LocalizedError, Equatable {
    case emptyTitle
    case taskNotFound

    var errorDescription: String? {
        switch self {
        case .emptyTitle:    return "Task title cannot be empty."
        case .taskNotFound:  return "Task not found."
        }
    }
}
