import Foundation

// ─────────────────────────────────────────────────────────────────
// Clean Architecture – Repository (Data Layer)
// The ONLY place that knows about data sources: CoreData, SQLite,
// REST API, etc. Conforms to the repository protocol defined in
// Domain — so Domain never depends on Data.
// ─────────────────────────────────────────────────────────────────
final class CleanTaskRepository: CleanTaskRepositoryProtocol {
    private var tasks: [CleanTask] = []

    func fetchAll() -> [CleanTask] {
        tasks
    }

    func add(title: String) throws -> CleanTask {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { throw CleanTaskError.emptyTitle }
        let task = CleanTask(title: trimmed)
        tasks.append(task)
        return task
    }

    func toggle(id: UUID) throws -> CleanTask {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            throw CleanTaskError.taskNotFound
        }
        tasks[index].isCompleted.toggle()
        return tasks[index]
    }

    func delete(id: UUID) {
        tasks.removeAll(where: { $0.id == id })
    }
}
