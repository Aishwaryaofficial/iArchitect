import Foundation
import Combine

// ──────────────────────────────────────────────────────────────────
// VIPER – Presenter
// Sits between View and Interactor. Formats data for display.
// Receives user events from View → dispatches to Interactor.
// Receives results from Interactor → formats and pushes to View.
// ──────────────────────────────────────────────────────────────────

// What the View can ask the Presenter to do
protocol VIPERTaskPresenterInputProtocol: AnyObject {
    func viewDidLoad()
    func didTapAddTask(title: String)
    func didTapToggleTask(id: UUID)
    func didTapDeleteTask(id: UUID)
}

// What the Presenter pushes to the View (for pure UIKit, this would
// call view methods; in SwiftUI we use @Published)
protocol VIPERTaskPresenterOutputProtocol: AnyObject {
    var tasks: [VIPERTask] { get }
    var errorMessage: String? { get }
}

final class VIPERTaskPresenter: ObservableObject,
                                VIPERTaskPresenterInputProtocol,
                                VIPERTaskInteractorOutputProtocol {
    // View observes these
    @Published private(set) var tasks: [VIPERTask] = []
    @Published var errorMessage: String?

    // Presenter's dependencies (set by Router/Assembler)
    var interactor: VIPERTaskInteractorInputProtocol?
    var router: VIPERTaskRouterProtocol?

    // MARK: - VIPERTaskPresenterInputProtocol

    func viewDidLoad() {
        interactor?.fetchTasks()
    }

    func didTapAddTask(title: String) {
        interactor?.addTask(title: title)
    }

    func didTapToggleTask(id: UUID) {
        interactor?.toggleTask(id: id)
    }

    func didTapDeleteTask(id: UUID) {
        interactor?.deleteTask(id: id)
    }

    // MARK: - VIPERTaskInteractorOutputProtocol

    func didFetchTasks(_ tasks: [VIPERTask]) {
        DispatchQueue.main.async {
            self.tasks = tasks
            self.errorMessage = nil
        }
    }

    func didFailWithError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
        }
    }
}
