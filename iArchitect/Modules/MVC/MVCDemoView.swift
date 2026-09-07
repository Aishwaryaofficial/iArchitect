import SwiftUI

// ──────────────────────────────────────────────────
// MVC – View
// Renders data and forwards user events to Controller.
// View has a direct reference to Controller, which is
// the key difference from MVP/MVVM.
// ──────────────────────────────────────────────────
struct MVCDemoView: View {
    @StateObject private var controller = MVCTaskController()
    @State private var newTaskTitle = ""

    var body: some View {
        VStack(spacing: 0) {
            addTaskBar
            taskList
        }
    }

    // MARK: - Sub-views

    private var addTaskBar: some View {
        HStack(spacing: 10) {
            TextField("New task…", text: $newTaskTitle)
                .textFieldStyle(.roundedBorder)
            Button("Add") {
                controller.userDidRequestAddTask(title: newTaskTitle)
                newTaskTitle = ""
            }
            .buttonStyle(.borderedProminent)
            .disabled(newTaskTitle.isEmpty)
        }
        .padding()
    }

    private var taskList: some View {
        List {
            ForEach(controller.tasks) { task in
                TaskRow(task: task) {
                    controller.userDidToggleTask(id: task.id)
                }
            }
            .onDelete { offsets in
                controller.userDidDeleteTasks(at: offsets)
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if controller.tasks.isEmpty {
                emptyState
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Tasks",
            systemImage: "checkmark.circle",
            description: Text("Add a task above to get started.")
        )
    }
}

// MARK: - Shared Row (reused across all pattern demos)

struct TaskRow: View {
    let task: MVCTask
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

#Preview {
    MVCDemoView()
}
