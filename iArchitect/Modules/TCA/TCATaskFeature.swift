import Foundation
import Combine

// ──────────────────────────────────────────────────────────────────
// TCA-Inspired (Unidirectional Data Flow)
// Based on The Composable Architecture pattern by Point-Free.
//
// The three core primitives:
//   State  — immutable snapshot of all UI state
//   Action — exhaustive enum of every event that can happen
//   Reducer — pure function: (inout State, Action) → Void
//   Store  — holds State, processes Actions via Reducer
//
// Data flow is strictly one-directional:
//   View → sends Action → Store → Reducer → new State → View
// ──────────────────────────────────────────────────────────────────

// MARK: - Entity

struct TCATask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

// MARK: - State (all UI state in one immutable snapshot)

struct TCATaskState: Equatable {
    var tasks: [TCATask]       = []
    var newTaskTitle: String   = ""
    var errorMessage: String?  = nil
    var actionLog: [String]    = []  // for teaching: shows which actions fired
}

// MARK: - Action (exhaustive enum — every possible event)

enum TCATaskAction: CustomStringConvertible {
    case newTitleChanged(String)
    case addButtonTapped
    case taskToggled(id: UUID)
    case taskDeleted(id: UUID)
    case errorDismissed

    // Human-readable name shown in the Action Log
    var description: String {
        switch self {
        case .newTitleChanged(let t): return "newTitleChanged(\"\(t)\")"
        case .addButtonTapped:        return "addButtonTapped"
        case .taskToggled(let id):    return "taskToggled(\(id.uuidString.prefix(8))…)"
        case .taskDeleted(let id):    return "taskDeleted(\(id.uuidString.prefix(8))…)"
        case .errorDismissed:         return "errorDismissed"
        }
    }
}

// MARK: - Reducer (pure function — no side effects)

struct TCATaskReducer {
    /// Mutates `state` based on `action`. Pure — always deterministic.
    func reduce(state: inout TCATaskState, action: TCATaskAction) {
        // Log the action for the in-app action log
        state.actionLog.insert("→ \(action)", at: 0)
        if state.actionLog.count > 10 { state.actionLog.removeLast() }

        switch action {
        case .newTitleChanged(let title):
            state.newTaskTitle = title

        case .addButtonTapped:
            let trimmed = state.newTaskTitle.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else {
                state.errorMessage = "Title cannot be empty."
                return
            }
            state.tasks.append(TCATask(title: trimmed))
            state.newTaskTitle = ""
            state.errorMessage = nil

        case .taskToggled(let id):
            guard let idx = state.tasks.firstIndex(where: { $0.id == id }) else { return }
            state.tasks[idx].isCompleted.toggle()

        case .taskDeleted(let id):
            state.tasks.removeAll(where: { $0.id == id })

        case .errorDismissed:
            state.errorMessage = nil
        }
    }
}

// MARK: - Store (holds State, routes Actions through Reducer)

final class TCATaskStore: ObservableObject {
    @Published private(set) var state: TCATaskState

    private let reducer = TCATaskReducer()

    init(initialState: TCATaskState = TCATaskState()) {
        self.state = initialState
    }

    /// The only way to change state: send an Action.
    func send(_ action: TCATaskAction) {
        reducer.reduce(state: &state, action: action)
    }
}
