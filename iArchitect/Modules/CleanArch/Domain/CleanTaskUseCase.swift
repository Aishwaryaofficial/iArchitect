import Foundation

// ─────────────────────────────────────────────────────────────────
// Clean Architecture – Use Case (Domain)
// Encapsulates a specific application use case.
// Depends only on abstractions (protocols), NOT on concrete data.
//
// The Dependency Rule: source code dependencies point inward.
// Use Cases know nothing about Repositories, ViewModels, or UI.
// ─────────────────────────────────────────────────────────────────

// Repository protocol — defined in Domain, implemented in Data
protocol CleanTaskRepositoryProtocol {
    func fetchAll() -> [CleanTask]
    func add(title: String) throws -> CleanTask
    func toggle(id: UUID) throws -> CleanTask
    func delete(id: UUID)
}

// Use Cases — one per business action
final class FetchTasksUseCase {
    private let repository: CleanTaskRepositoryProtocol
    init(repository: CleanTaskRepositoryProtocol) { self.repository = repository }

    func execute() -> [CleanTask] {
        repository.fetchAll()
    }
}

final class AddTaskUseCase {
    private let repository: CleanTaskRepositoryProtocol
    init(repository: CleanTaskRepositoryProtocol) { self.repository = repository }

    func execute(title: String) throws -> CleanTask {
        try repository.add(title: title)
    }
}

final class ToggleTaskUseCase {
    private let repository: CleanTaskRepositoryProtocol
    init(repository: CleanTaskRepositoryProtocol) { self.repository = repository }

    func execute(id: UUID) throws -> CleanTask {
        try repository.toggle(id: id)
    }
}

final class DeleteTaskUseCase {
    private let repository: CleanTaskRepositoryProtocol
    init(repository: CleanTaskRepositoryProtocol) { self.repository = repository }

    func execute(id: UUID) {
        repository.delete(id: id)
    }
}
