import SwiftUI

// ──────────────────────────────────────────────────────────────────
// TCA – View
// Reads from Store.state. Sends Actions via store.send(_:).
// NO logic here — it is a rendering function of the State.
// ──────────────────────────────────────────────────────────────────
struct TCADemoView: View {
    @StateObject private var store = TCATaskStore()
    @State private var showActionLog = false

    var body: some View {
        VStack(spacing: 0) {
            flowIndicator
            errorBanner
            addTaskBar
            taskList
            actionLogButton
            if showActionLog { actionLogPanel }
        }
    }

    // MARK: - Sub-views

    private var flowIndicator: some View {
        HStack(spacing: 4) {
            badge("View", color: .blue)
            Image(systemName: "arrow.right").font(.caption2).foregroundStyle(.secondary)
            badge("Action", color: .orange)
            Image(systemName: "arrow.right").font(.caption2).foregroundStyle(.secondary)
            badge("Reducer", color: .purple)
            Image(systemName: "arrow.right").font(.caption2).foregroundStyle(.secondary)
            badge("State", color: .green)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
    }

    @ViewBuilder
    private var errorBanner: some View {
        if let error = store.state.errorMessage {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                Text(error).font(.caption).foregroundStyle(.orange)
                Spacer()
                Button("✕") { store.send(.errorDismissed) }.font(.caption)
            }
            .padding(.horizontal).padding(.vertical, 6)
            .background(Color.orange.opacity(0.12))
        }
    }

    private var addTaskBar: some View {
        HStack(spacing: 10) {
            // TextField is bound to State via Binding(get:set:)
            // set fires an Action, not a direct mutation
            TextField("New task…", text: Binding(
                get: { store.state.newTaskTitle },
                set: { store.send(.newTitleChanged($0)) }
            ))
            .textFieldStyle(.roundedBorder)
            .onSubmit { store.send(.addButtonTapped) }

            Button("Add") { store.send(.addButtonTapped) }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var taskList: some View {
        List {
            ForEach(store.state.tasks) { task in
                TCATaskRow(task: task) {
                    store.send(.taskToggled(id: task.id))
                }
            }
            .onDelete { offsets in
                offsets.forEach { idx in
                    store.send(.taskDeleted(id: store.state.tasks[idx].id))
                }
            }
        }
        .listStyle(.insetGrouped)
        .overlay {
            if store.state.tasks.isEmpty {
                ContentUnavailableView("No Tasks", systemImage: "checkmark.circle",
                                       description: Text("Add a task above."))
            }
        }
    }

    private var actionLogButton: some View {
        Button {
            withAnimation { showActionLog.toggle() }
        } label: {
            Label(showActionLog ? "Hide Action Log" : "Show Action Log",
                  systemImage: "terminal")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private var actionLogPanel: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Recent Actions").font(.caption2).bold().foregroundStyle(.secondary)
            ForEach(store.state.actionLog, id: \.self) { log in
                Text(log)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.green)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.black.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.bottom, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func badge(_ label: String, color: Color) -> some View {
        Text(label)
            .font(.caption2)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

private struct TCATaskRow: View {
    let task: TCATask
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

#Preview { TCADemoView() }
