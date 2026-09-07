import SwiftUI

// ──────────────────────────────────────────────────────────────────
// VIPER – View
// Completely passive UI layer. Delegates ALL user events to the
// Presenter. Must NOT contain any conditional business logic.
// ──────────────────────────────────────────────────────────────────
struct VIPERDemoView: View {
    // Assembler holds the fully-wired presenter
    @StateObject private var assembler = VIPERTaskAssembler()
    @State private var newTaskTitle = ""

    private var presenter: VIPERTaskPresenter { assembler.presenter }

    var body: some View {
        VStack(spacing: 0) {
            errorBanner
            addTaskBar
            taskList
        }
        .onAppear { presenter.viewDidLoad() }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var errorBanner: some View {
        if let error = presenter.errorMessage {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                Text(error).font(.caption).foregroundStyle(.orange)
                Spacer()
                Button("✕") { presenter.errorMessage = nil }.font(.caption)
            }
            .padding(.horizontal).padding(.vertical, 8)
            .background(Color.orange.opacity(0.12))
        }
    }

    private var addTaskBar: some View {
        HStack(spacing: 10) {
            TextField("New task…", text: $newTaskTitle)
                .textFieldStyle(.roundedBorder)
                .onSubmit { addTask() }
            Button("Add") { addTask() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var taskList: some View {
        List {
            ForEach(presenter.tasks) { task in
                VIPERTaskRow(task: task) {
                    presenter.didTapToggleTask(id: task.id)
                }
            }
            .onDelete { offsets in
                offsets.forEach { idx in
                    presenter.didTapDeleteTask(id: presenter.tasks[idx].id)
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if presenter.tasks.isEmpty {
                ContentUnavailableView("No Tasks", systemImage: "checkmark.circle",
                                       description: Text("Add a task above."))
            }
        }
    }

    private func addTask() {
        presenter.didTapAddTask(title: newTaskTitle)
        if presenter.errorMessage == nil { newTaskTitle = "" }
    }
}

private struct VIPERTaskRow: View {
    let task: VIPERTask
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

#Preview { VIPERDemoView() }
