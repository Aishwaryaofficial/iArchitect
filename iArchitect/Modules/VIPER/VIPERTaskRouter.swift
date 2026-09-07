import SwiftUI

// ──────────────────────────────────────────────────────────────────
// VIPER – Router
// Owns navigation. Creates/destroys screens and wires all VIPER
// components together. This is the "assembler" of the module.
//
// Key rule: ALL component wiring happens here, not in the view.
// ──────────────────────────────────────────────────────────────────

protocol VIPERTaskRouterProtocol: AnyObject {
    func navigateToDetail(task: VIPERTask, from view: AnyView)
}

final class VIPERTaskRouter: VIPERTaskRouterProtocol {
    func navigateToDetail(task: VIPERTask, from view: AnyView) {
        // In a real app: push VIPERTaskDetailView onto navigation stack
        print("Router: navigate to detail for '\(task.title)'")
    }
}

// ── Module Assembler ──────────────────────────────────────────────
// This factory wires all VIPER components and returns the root View.
// It is the ONLY place that knows about all five components.
final class VIPERTaskAssembler: ObservableObject {
    let presenter = VIPERTaskPresenter()

    init() {
        let interactor = VIPERTaskInteractor()
        let router     = VIPERTaskRouter()

        presenter.interactor = interactor
        presenter.router     = router
        interactor.output    = presenter  // Interactor → Presenter output
    }
}
