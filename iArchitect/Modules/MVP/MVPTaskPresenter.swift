import Foundation
import Combine

// ──────────────────────────────────────────────────────────
// MVP – Presenter
// Contains ALL business logic. The Presenter is completely
// unaware of UIKit/SwiftUI — it communicates with the View
// only via the MVPTaskViewProtocol (Dependency Inversion).
//
// Key MVP rule: Presenter NEVER imports UIKit or SwiftUI.
// ──────────────────────────────────────────────────────────

// View protocol: defines what the Presenter can ask the View to do.
// The real View (SwiftUI) conforms to this. For testing, a mock can.
protocol MVPTaskViewProtocol: AnyObject {
    func displayTasks(_ tasks: [MVPTask])
    func displayError(_ message: String)
    func clearError()
}

class MVPTaskPresenter: ObservableObject {
    // Published for SwiftUI binding — in pure MVP these would
    // be method calls on the MVPTaskViewProtocol delegate
    @Published private(set) var tasks: [MVPTask] = []
    @Published var errorMessage: String?

    // Weak reference to view prevents retain cycle
    weak var view: MVPTaskViewProtocol?

    private let store = MVPTaskStore()

    func addTask(title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Task title cannot be empty."
            view?.displayError("Task title cannot be empty.")
            return
        }
        store.add(title: title)
        refresh()
    }

    func toggleTask(id: UUID) {
        store.toggle(id: id)
        refresh()
    }

    func deleteTasks(at offsets: IndexSet) {
        store.delete(at: offsets)
        refresh()
    }

    // MARK: - Private

    private func refresh() {
        tasks = store.tasks
        errorMessage = nil
        view?.displayTasks(tasks)
        view?.clearError()
    }
}
