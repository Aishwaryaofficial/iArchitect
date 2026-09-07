import Foundation

// ─────────────────────────────────────────────
// MVC – Model
// Pure data. No knowledge of View or Controller.
// ─────────────────────────────────────────────
struct MVCTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

// The Model class manages a collection of tasks.
// It has NO reference to any UI component.
class MVCTaskModel {
    private(set) var tasks: [MVCTask] = []

    func addTask(title: String) {
        tasks.append(MVCTask(title: title))
    }

    func toggleTask(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        tasks[index].isCompleted.toggle()
    }

    func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}
