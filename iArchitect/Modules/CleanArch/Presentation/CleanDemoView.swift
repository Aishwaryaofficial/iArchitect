import SwiftUI

// ──────────────────────────────────────────────────────────────
// Clean Architecture – View (Presentation Layer)
// Only knows about the ViewModel. Knows nothing about Use Cases,
// Repository, or Domain Entities.
// ──────────────────────────────────────────────────────────────
struct CleanDemoView: View {
    @StateObject private var viewModel = CleanTaskViewModel()
    @State private var newTaskTitle = ""

    var body: some View {
        VStack(spacing: 0) {
            layerBadgeBar
            errorBanner
            addTaskBar
            taskList
        }
    }

    // MARK: - Sub-views

    // Visual reminder of the three layers
    private var layerBadgeBar: some View {
        HStack(spacing: 6) {
            layerBadge("Presentation", color: .blue)
            Image(systemName: "arrow.right").font(.caption2).foregroundStyle(.secondary)
            layerBadge("Domain", color: .purple)
            Image(systemName: "arrow.right").font(.caption2).foregroundStyle(.secondary)
            layerBadge("Data", color: .orange)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
    }

    @ViewBuilder
    private var errorBanner: some View {
        if let error = viewModel.errorMessage {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                Text(error).font(.caption).foregroundStyle(.orange)
                Spacer()
            }
            .padding(.horizontal).padding(.vertical, 6)
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
            ForEach(viewModel.tasks) { task in
                CleanTaskRow(task: task) {
                    viewModel.toggleTask(id: task.id)
                }
            }
            .onDelete { offsets in
                offsets.forEach { viewModel.deleteTask(id: viewModel.tasks[$0].id) }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if viewModel.tasks.isEmpty {
                ContentUnavailableView("No Tasks", systemImage: "checkmark.circle",
                                       description: Text("Add a task above."))
            }
        }
    }

    private func addTask() {
        viewModel.addTask(title: newTaskTitle)
        if viewModel.errorMessage == nil { newTaskTitle = "" }
    }

    private func layerBadge(_ label: String, color: Color) -> some View {
        Text(label)
            .font(.caption2)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

private struct CleanTaskRow: View {
    let task: CleanTask
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

#Preview { CleanDemoView() }
