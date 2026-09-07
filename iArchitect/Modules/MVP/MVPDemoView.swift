import SwiftUI

// ─────────────────────────────────────────────────────────────
// MVP – View
// Completely passive. Renders what the Presenter tells it.
// Does NOT contain any business logic — only display + routing
// user events to the Presenter.
//
// NOTE: In UIKit MVP, UIViewController conforms to MVPTaskViewProtocol.
// In SwiftUI, structs cannot adopt AnyObject protocols.
// We use @Published bindings as the notification mechanism instead —
// the Presenter still owns ALL logic; the View stays passive.
// ─────────────────────────────────────────────────────────────
struct MVPDemoView: View {
    @StateObject private var presenter = MVPTaskPresenter()
    @State private var newTaskTitle = ""

    var body: some View {
        VStack(spacing: 0) {
            errorBanner
            addTaskBar
            taskList
        }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var errorBanner: some View {
        if let error = presenter.errorMessage {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.orange)
                Spacer()
                Button("Dismiss") { presenter.errorMessage = nil }
                    .font(.caption)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.1))
        }
    }

    private var addTaskBar: some View {
        HStack(spacing: 10) {
            TextField("New task…", text: $newTaskTitle)
                .textFieldStyle(.roundedBorder)
            Button("Add") {
                presenter.addTask(title: newTaskTitle)
                if presenter.errorMessage == nil { newTaskTitle = "" }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var taskList: some View {
        List {
            ForEach(presenter.tasks) { task in
                MVPTaskRow(task: task) {
                    presenter.toggleTask(id: task.id)
                }
            }
            .onDelete { offsets in
                presenter.deleteTasks(at: offsets)
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
}

private struct MVPTaskRow: View {
    let task: MVPTask
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

#Preview { MVPDemoView() }
