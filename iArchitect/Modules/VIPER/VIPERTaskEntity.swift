import Foundation

// ─────────────────────────────────────────────────
// VIPER – Entity
// Plain data object with no logic.
// In VIPER, Entities are ONLY manipulated by the
// Interactor — never directly by the View or Presenter.
// ─────────────────────────────────────────────────
struct VIPERTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}
