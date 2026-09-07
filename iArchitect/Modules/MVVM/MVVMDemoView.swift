import SwiftUI

// ──────────────────────────────────────────────────────────────
// MVVM – View
// Binds to the ViewModel using @StateObject and $.
// Zero business logic — View is a pure rendering function of
// the ViewModel's published state.
// ──────────────────────────────────────────────────────────────
struct MVVMDemoView: View {
    @StateObject private var viewModel = MVVMTaskViewModel()

    var body: some View {
        VStack(spacing: 0) {
            statsBar
            addTaskBar
            taskList
        }
    }

    // MARK: - Sub-views

    private var statsBar: some View {
        HStack(spacing: 16) {
            Label("\(viewModel.tasks.count) total", systemImage: "list.bullet")
            Spacer()
            Label("\(viewModel.pendingCount) pending", systemImage: "circle")
                .foregroundStyle(.orange)
            Label("\(viewModel.completedCount) done", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        }
        .font(.caption)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.regularMaterial)
    }

    private var addTaskBar: some View {
        HStack(spacing: 10) {
            // Two-way binding: $viewModel.newTaskTitle
            TextField("New task…", text: $viewModel.newTaskTitle)
                .textFieldStyle(.roundedBorder)
                .onSubmit { viewModel.addTask() }
            Button("Add") { viewModel.addTask() }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.newTaskTitle.isEmpty)
        }
        .padding()
    }

    private var taskList: some View {
        List {
            ForEach(viewModel.tasks) { task in
                MVVMTaskRow(task: task) {
                    viewModel.toggleTask(task)
                }
            }
            .onDelete(perform: viewModel.deleteTasks)
        }
        .listStyle(.insetGrouped)
        .overlay {
            if viewModel.tasks.isEmpty {
                ContentUnavailableView("No Tasks", systemImage: "checkmark.circle",
                                       description: Text("Add a task above."))
            }
        }
    }
}

private struct MVVMTaskRow: View {
    let task: MVVMTask
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(task.isCompleted ? Color.green : Color.secondary)
                .font(.title3)
                .onTapGesture { onToggle() }
            Text(task.title)
                .strikethrough(task.isCompleted, color: .secondary)
                .foregroundStyle(task.isCompleted ? Color.secondary : Color.primary)
            Spacer()
        }
    }
}

#Preview { MVVMDemoView() }
