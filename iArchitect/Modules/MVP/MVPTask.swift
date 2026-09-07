import Foundation

// ─────────────────────────────────────────
// MVP – Model
// Plain data. No framework dependencies.
// ─────────────────────────────────────────
struct MVPTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

// Internal data store (separate from domain model)
class MVPTaskStore {
    private(set) var tasks: [MVPTask] = []

    func add(title: String) {
        tasks.append(MVPTask(title: title))
    }

    func toggle(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isCompleted.toggle()
    }

    func delete(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}
