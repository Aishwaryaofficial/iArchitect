import Foundation
import Combine

// ──────────────────────────────────────────────────────────────
// MVVM – ViewModel
// Exposes reactive state the View observes via @Published.
// Contains all presentation logic but no UIKit/SwiftUI imports.
//
// Key MVVM feature: two-way data binding via Combine pipelines.
// The View reads @Published properties and binds inputs via $.
// ──────────────────────────────────────────────────────────────
final class MVVMTaskViewModel: ObservableObject {
    // Outputs — View observes these
    @Published private(set) var tasks: [MVVMTask] = []
    @Published private(set) var completedCount: Int = 0
    @Published private(set) var pendingCount: Int = 0

    // Input — View binds to this with TextField
    @Published var newTaskTitle: String = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Reactive pipeline: derive counts from tasks automatically
        $tasks
            .map { $0.filter(\.isCompleted).count }
            .assign(to: &$completedCount)

        $tasks
            .map { $0.filter { !$0.isCompleted }.count }
            .assign(to: &$pendingCount)
    }

    // MARK: - Intents (called by View)

    func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        tasks.append(MVVMTask(title: trimmed))
        newTaskTitle = ""
    }

    func toggleTask(_ task: MVVMTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isCompleted.toggle()
    }

    func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}
