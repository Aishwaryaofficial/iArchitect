import Foundation
import Combine

// ──────────────────────────────────────────────────────
// MVC – Controller
// Mediates between Model and View.
// In UIKit iOS MVC this is a UIViewController subclass.
// Here we use ObservableObject to bridge to SwiftUI.
// The Controller is where the "Massive View Controller"
// anti-pattern tends to grow — a common interview topic.
// ──────────────────────────────────────────────────────
class MVCTaskController: ObservableObject {
    // Controller exposes model state to the View
    @Published private(set) var tasks: [MVCTask] = []

    private let model = MVCTaskModel()

    // Controller translates user intents into model mutations
    func userDidRequestAddTask(title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        model.addTask(title: title)
        syncTasks()
    }

    func userDidToggleTask(id: UUID) {
        model.toggleTask(id: id)
        syncTasks()
    }

    func userDidDeleteTasks(at offsets: IndexSet) {
        model.deleteTask(at: offsets)
        syncTasks()
    }

    // Private: keeps View-published state in sync with Model
    private func syncTasks() {
        tasks = model.tasks
    }
}
