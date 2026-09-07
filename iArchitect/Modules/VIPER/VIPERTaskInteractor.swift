import Foundation

// ──────────────────────────────────────────────────────────
// VIPER – Interactor
// Contains ALL business rules & data logic.
// Only knows about Entities. Never imports UIKit/SwiftUI.
// Receives requests from Presenter (Input) and
// delivers results back via Output protocol.
// ──────────────────────────────────────────────────────────

// Input protocol: what the Presenter asks the Interactor to do
protocol VIPERTaskInteractorInputProtocol: AnyObject {
    func fetchTasks()
    func addTask(title: String)
    func toggleTask(id: UUID)
    func deleteTask(id: UUID)
}

// Output protocol: how the Interactor delivers results to Presenter
protocol VIPERTaskInteractorOutputProtocol: AnyObject {
    func didFetchTasks(_ tasks: [VIPERTask])
    func didFailWithError(_ message: String)
}

final class VIPERTaskInteractor: VIPERTaskInteractorInputProtocol {
    // Weak to prevent Interactor → Presenter retain cycle
    weak var output: VIPERTaskInteractorOutputProtocol?

    private var tasks: [VIPERTask] = []

    func fetchTasks() {
        output?.didFetchTasks(tasks)
    }

    func addTask(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            output?.didFailWithError("Task title cannot be empty.")
            return
        }
        tasks.append(VIPERTask(title: trimmed))
        output?.didFetchTasks(tasks)
    }

    func toggleTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isCompleted.toggle()
        output?.didFetchTasks(tasks)
    }

    func deleteTask(id: UUID) {
        tasks.removeAll(where: { $0.id == id })
        output?.didFetchTasks(tasks)
    }
}
