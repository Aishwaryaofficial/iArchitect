import Foundation
import Combine

// ─────────────────────────────────────────────────────────────────
// Clean Architecture – ViewModel (Presentation Layer)
// Bridges Domain Use Cases to SwiftUI.
// Depends on Domain (Use Cases) — NEVER on Data (Repository).
// This demonstrates the Dependency Rule in action.
// ─────────────────────────────────────────────────────────────────
final class CleanTaskViewModel: ObservableObject {
    @Published private(set) var tasks: [CleanTask] = []
    @Published var errorMessage: String?

    // Use Cases are injected — not created internally
    private let fetchUseCase:  FetchTasksUseCase
    private let addUseCase:    AddTaskUseCase
    private let toggleUseCase: ToggleTaskUseCase
    private let deleteUseCase: DeleteTaskUseCase

    // Default init uses the concrete repository (injected from outside)
    init(repository: CleanTaskRepositoryProtocol = CleanTaskRepository()) {
        fetchUseCase  = FetchTasksUseCase(repository: repository)
        addUseCase    = AddTaskUseCase(repository: repository)
        toggleUseCase = ToggleTaskUseCase(repository: repository)
        deleteUseCase = DeleteTaskUseCase(repository: repository)
        loadTasks()
    }

    func addTask(title: String) {
        do {
            _ = try addUseCase.execute(title: title)
            loadTasks()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleTask(id: UUID) {
        do {
            _ = try toggleUseCase.execute(id: id)
            loadTasks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteTask(id: UUID) {
        deleteUseCase.execute(id: id)
        loadTasks()
    }

    // MARK: - Private

    private func loadTasks() {
        tasks = fetchUseCase.execute()
    }
}
