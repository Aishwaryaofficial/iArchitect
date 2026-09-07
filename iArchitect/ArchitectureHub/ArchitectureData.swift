import SwiftUI

// ──────────────────────────────────────────────────────────────────
// Architecture Data Models + Content
// All pattern metadata, layer descriptions, code snippets,
// pros/cons, and use cases — the educational heart of the app.
// ──────────────────────────────────────────────────────────────────

// MARK: - Models

struct ArchPattern: Identifiable {
    let id: String
    let name: String
    let acronym: String
    let tagline: String
    let icon: String
    let color: Color
    let layers: [PatternLayer]
    let keyPrinciples: [String]
    let pros: [String]
    let cons: [String]
    let useCases: [String]
    let files: [CodeFile]
    let diagramNodes: [DiagramNode]
    let diagramEdges: [DiagramEdge]
}

struct PatternLayer: Identifiable {
    let id = UUID()
    let name: String
    let role: String
    let color: Color
}

struct CodeFile: Identifiable {
    let id = UUID()
    let filename: String
    let layerName: String
    let layerColor: Color
    let code: String
}

struct DiagramNode: Identifiable {
    let id: String
    let label: String
    let sublabel: String
    let color: Color
    let row: Int      // layout row (0 = top)
    let col: Int      // layout column
}

struct DiagramEdge: Identifiable {
    let id = UUID()
    let fromNode: String
    let toNode: String
    let label: String
    let isBidirectional: Bool
}

// MARK: - All Patterns

struct ArchitectureLibrary {
    static let all: [ArchPattern] = [mvc, mvp, mvvm, viper, cleanArch, tca]

    // ─────────────────────────────── MVC ───────────────────────────────
    static let mvc = ArchPattern(
        id: "mvc",
        name: "Model-View-Controller",
        acronym: "MVC",
        tagline: "Apple's default iOS pattern — simple but prone to Massive View Controller.",
        icon: "square.3.layers.3d.top.filled",
        color: .blue,
        layers: [
            PatternLayer(name: "Model",      role: "Holds application data and business rules. No UI dependencies.", color: .green),
            PatternLayer(name: "View",        role: "Renders UI. Sends user events to the Controller.", color: .blue),
            PatternLayer(name: "Controller",  role: "Glue between Model and View. Mediates updates.", color: .orange),
        ],
        keyPrinciples: [
            "Separation of data (Model) from display (View)",
            "Controller mediates communication between Model and View",
            "View has a direct reference to Controller",
            "Model is independent of View and Controller",
            "Data flows: User → View → Controller → Model → Controller → View"
        ],
        pros: [
            "Simple and easy to understand",
            "Built into UIKit (UIViewController is the Controller)",
            "Great starting point for small apps"
        ],
        cons: [
            "Controller tends to grow very large (Massive ViewController)",
            "Hard to unit test — Controller is tightly coupled to UIKit",
            "View and Controller often become entangled"
        ],
        useCases: ["Simple screens", "UIKit table views", "Small to medium apps"],
        files: [
            CodeFile(filename: "MVCTaskModel.swift", layerName: "Model", layerColor: .green,
                     code: mvcModelCode),
            CodeFile(filename: "MVCTaskController.swift", layerName: "Controller", layerColor: .orange,
                     code: mvcControllerCode),
            CodeFile(filename: "MVCDemoView.swift", layerName: "View", layerColor: .blue,
                     code: mvcViewCode),
        ],
        diagramNodes: [
            DiagramNode(id: "model",      label: "Model",      sublabel: "Data & Rules", color: .green,  row: 1, col: 1),
            DiagramNode(id: "view",       label: "View",       sublabel: "UI Rendering", color: .blue,   row: 0, col: 0),
            DiagramNode(id: "controller", label: "Controller", sublabel: "Mediator",     color: .orange, row: 0, col: 2),
        ],
        diagramEdges: [
            DiagramEdge(fromNode: "view",       toNode: "controller", label: "user events", isBidirectional: false),
            DiagramEdge(fromNode: "controller", toNode: "model",      label: "updates",     isBidirectional: false),
            DiagramEdge(fromNode: "model",      toNode: "controller", label: "notifies",    isBidirectional: false),
            DiagramEdge(fromNode: "controller", toNode: "view",       label: "renders",     isBidirectional: false),
        ]
    )

    // ─────────────────────────────── MVP ───────────────────────────────
    static let mvp = ArchPattern(
        id: "mvp",
        name: "Model-View-Presenter",
        acronym: "MVP",
        tagline: "Presenter replaces Controller, decoupling logic from UIKit for testability.",
        icon: "square.3.layers.3d.middle.filled",
        color: .purple,
        layers: [
            PatternLayer(name: "Model",     role: "Data structures and persistence. No UI knowledge.", color: .green),
            PatternLayer(name: "View",      role: "Passive — only renders and delegates events. Conforms to a View Protocol.", color: .blue),
            PatternLayer(name: "Presenter", role: "All logic. Talks to View via protocol. Fully testable without UIKit.", color: .purple),
        ],
        keyPrinciples: [
            "Presenter has NO UIKit import — 100% testable",
            "View is completely passive (dumb view)",
            "Communication via View Protocol (Dependency Inversion)",
            "Presenter holds weak reference to View to avoid retain cycle",
            "Data flows: User → View → Presenter → Model → Presenter → View (via protocol)"
        ],
        pros: [
            "Presenter is fully unit-testable — no UIKit needed",
            "View is a thin rendering layer (easy to replace)",
            "Clear separation of concerns"
        ],
        cons: [
            "More boilerplate than MVC (View Protocol + Presenter)",
            "Presenter can still grow large",
            "One Presenter per screen (not composable)"
        ],
        useCases: ["UIKit screens requiring high test coverage", "Legacy codebases being modernised"],
        files: [
            CodeFile(filename: "MVPTask.swift",          layerName: "Model",     layerColor: .green,  code: mvpModelCode),
            CodeFile(filename: "MVPTaskPresenter.swift", layerName: "Presenter", layerColor: .purple, code: mvpPresenterCode),
            CodeFile(filename: "MVPDemoView.swift",      layerName: "View",      layerColor: .blue,   code: mvpViewCode),
        ],
        diagramNodes: [
            DiagramNode(id: "model",     label: "Model",     sublabel: "Data Store",    color: .green,  row: 1, col: 1),
            DiagramNode(id: "view",      label: "View",      sublabel: "Passive UI",    color: .blue,   row: 0, col: 0),
            DiagramNode(id: "presenter", label: "Presenter", sublabel: "All Logic",     color: .purple, row: 0, col: 2),
        ],
        diagramEdges: [
            DiagramEdge(fromNode: "view",      toNode: "presenter", label: "user events",      isBidirectional: false),
            DiagramEdge(fromNode: "presenter", toNode: "view",      label: "via protocol",     isBidirectional: false),
            DiagramEdge(fromNode: "presenter", toNode: "model",     label: "reads / writes",   isBidirectional: false),
        ]
    )

    // ─────────────────────────────── MVVM ───────────────────────────────
    static let mvvm = ArchPattern(
        id: "mvvm",
        name: "Model-View-ViewModel",
        acronym: "MVVM",
        tagline: "SwiftUI's native pattern — reactive bindings replace manual View updates.",
        icon: "square.3.layers.3d.bottom.filled",
        color: .teal,
        layers: [
            PatternLayer(name: "Model",     role: "Plain data structures. No framework dependencies.", color: .green),
            PatternLayer(name: "View",      role: "Binds to ViewModel using @StateObject and $. Pure SwiftUI rendering.", color: .blue),
            PatternLayer(name: "ViewModel", role: "Exposes @Published state. No UIKit. Easily unit tested.", color: .teal),
        ],
        keyPrinciples: [
            "Two-way data binding via @Published and $",
            "ViewModel transforms Model data for display",
            "View observes ViewModel — no manual UI updates needed",
            "Combine pipelines for reactive derived state",
            "ViewModel has no UIKit/SwiftUI imports"
        ],
        pros: [
            "Natural fit for SwiftUI",
            "Combine makes reactive pipelines elegant",
            "ViewModel is easily unit tested",
            "Binding eliminates manual UI sync code"
        ],
        cons: [
            "Can over-use Combine for simple state",
            "ViewModel can still grow large without further structure",
            "Two-way bindings can cause unexpected update loops"
        ],
        useCases: ["All SwiftUI apps", "Data-driven screens", "Real-time updates"],
        files: [
            CodeFile(filename: "MVVMTask.swift",            layerName: "Model",     layerColor: .green, code: mvvmModelCode),
            CodeFile(filename: "MVVMTaskViewModel.swift",   layerName: "ViewModel", layerColor: .teal,  code: mvvmViewModelCode),
            CodeFile(filename: "MVVMDemoView.swift",        layerName: "View",      layerColor: .blue,  code: mvvmViewCode),
        ],
        diagramNodes: [
            DiagramNode(id: "model",     label: "Model",     sublabel: "Data",          color: .green, row: 1, col: 1),
            DiagramNode(id: "view",      label: "View",      sublabel: "@StateObject",  color: .blue,  row: 0, col: 0),
            DiagramNode(id: "viewmodel", label: "ViewModel", sublabel: "@Published",    color: .teal,  row: 0, col: 2),
        ],
        diagramEdges: [
            DiagramEdge(fromNode: "view",      toNode: "viewmodel", label: "$ binding",         isBidirectional: true),
            DiagramEdge(fromNode: "viewmodel", toNode: "model",     label: "reads / writes",    isBidirectional: false),
        ]
    )

    // ─────────────────────────────── VIPER ───────────────────────────────
    static let viper = ArchPattern(
        id: "viper",
        name: "VIPER",
        acronym: "VIPER",
        tagline: "Five strict layers — maximum separation of concerns and testability.",
        icon: "pentagon.fill",
        color: .red,
        layers: [
            PatternLayer(name: "View",       role: "Passive UI. Delegates events to Presenter.", color: .blue),
            PatternLayer(name: "Interactor", role: "Business logic. Manipulates Entities only.", color: .orange),
            PatternLayer(name: "Presenter",  role: "Formats data for display. Bridges View ↔ Interactor.", color: .purple),
            PatternLayer(name: "Entity",     role: "Plain data structures. No logic.", color: .green),
            PatternLayer(name: "Router",     role: "Navigation logic. Creates and wires all VIPER components.", color: .red),
        ],
        keyPrinciples: [
            "Each layer has exactly ONE responsibility",
            "All communication is via protocols (max testability)",
            "Router is the only place that knows about all layers",
            "Interactor never imports UIKit",
            "Entities are pure data — no methods beyond init"
        ],
        pros: [
            "Extremely high testability — every layer mockable",
            "Maximum separation of concerns",
            "Scales well to large teams (one developer per layer)",
            "Router encapsulates navigation completely"
        ],
        cons: [
            "Very high boilerplate (5x more files than MVC)",
            "Over-engineering for small screens",
            "Learning curve is steep"
        ],
        useCases: ["Enterprise iOS apps", "Large team projects", "Screens with complex business logic"],
        files: [
            CodeFile(filename: "VIPERTaskEntity.swift",     layerName: "Entity",     layerColor: .green,  code: viperEntityCode),
            CodeFile(filename: "VIPERTaskInteractor.swift", layerName: "Interactor", layerColor: .orange, code: viperInteractorCode),
            CodeFile(filename: "VIPERTaskPresenter.swift",  layerName: "Presenter",  layerColor: .purple, code: viperPresenterCode),
            CodeFile(filename: "VIPERTaskRouter.swift",     layerName: "Router",     layerColor: .red,    code: viperRouterCode),
            CodeFile(filename: "VIPERDemoView.swift",       layerName: "View",       layerColor: .blue,   code: viperViewCode),
        ],
        diagramNodes: [
            DiagramNode(id: "view",       label: "View",       sublabel: "UI",           color: .blue,   row: 0, col: 1),
            DiagramNode(id: "presenter",  label: "Presenter",  sublabel: "Formatter",    color: .purple, row: 1, col: 1),
            DiagramNode(id: "interactor", label: "Interactor", sublabel: "Business",     color: .orange, row: 2, col: 0),
            DiagramNode(id: "entity",     label: "Entity",     sublabel: "Data",         color: .green,  row: 2, col: 2),
            DiagramNode(id: "router",     label: "Router",     sublabel: "Navigation",   color: .red,    row: 0, col: 3),
        ],
        diagramEdges: [
            DiagramEdge(fromNode: "view",       toNode: "presenter",  label: "user events",  isBidirectional: false),
            DiagramEdge(fromNode: "presenter",  toNode: "view",       label: "display data", isBidirectional: false),
            DiagramEdge(fromNode: "presenter",  toNode: "interactor", label: "requests",     isBidirectional: false),
            DiagramEdge(fromNode: "interactor", toNode: "presenter",  label: "results",      isBidirectional: false),
            DiagramEdge(fromNode: "interactor", toNode: "entity",     label: "manipulates",  isBidirectional: false),
            DiagramEdge(fromNode: "view",       toNode: "router",     label: "navigate",     isBidirectional: false),
        ]
    )

    // ─────────────────────────────── Clean Architecture ───────────────────────────────
    static let cleanArch = ArchPattern(
        id: "clean",
        name: "Clean Architecture",
        acronym: "Clean",
        tagline: "Concentric layers — dependencies always point inward toward Domain.",
        icon: "circles.hexagongrid.fill",
        color: .indigo,
        layers: [
            PatternLayer(name: "Domain",       role: "Innermost circle. Entities + Use Cases. Zero framework dependencies.", color: .purple),
            PatternLayer(name: "Data",         role: "Implements repository protocols. Knows about CoreData/API/etc.", color: .orange),
            PatternLayer(name: "Presentation", role: "ViewModel + View. Depends on Domain Use Cases only.", color: .blue),
        ],
        keyPrinciples: [
            "Dependency Rule: dependencies point inward only",
            "Domain knows nothing about Presentation or Data",
            "Use Cases encapsulate one application action each",
            "Repository protocol defined in Domain, implemented in Data",
            "Dependency Injection wires the layers at startup"
        ],
        pros: [
            "Domain layer is completely framework-free",
            "Swap data sources or UI frameworks without touching Domain",
            "Each layer is independently testable",
            "Scales to very large codebases"
        ],
        cons: [
            "Higher upfront complexity",
            "More files and indirection",
            "Can be overkill for simple apps"
        ],
        useCases: ["Large apps with multiple data sources", "Apps that may migrate UI frameworks", "Long-lived codebases"],
        files: [
            CodeFile(filename: "CleanTask.swift",             layerName: "Domain / Entity",   layerColor: .purple, code: cleanEntityCode),
            CodeFile(filename: "CleanTaskUseCase.swift",      layerName: "Domain / Use Case", layerColor: .purple, code: cleanUseCaseCode),
            CodeFile(filename: "CleanTaskRepository.swift",   layerName: "Data",              layerColor: .orange, code: cleanRepositoryCode),
            CodeFile(filename: "CleanTaskViewModel.swift",    layerName: "Presentation",      layerColor: .blue,   code: cleanViewModelCode),
        ],
        diagramNodes: [
            DiagramNode(id: "entity",     label: "Entity",       sublabel: "Domain",       color: .purple, row: 2, col: 1),
            DiagramNode(id: "usecase",    label: "Use Case",     sublabel: "Domain",       color: .purple, row: 1, col: 1),
            DiagramNode(id: "repository", label: "Repository",   sublabel: "Data",         color: .orange, row: 0, col: 0),
            DiagramNode(id: "viewmodel",  label: "ViewModel",    sublabel: "Presentation", color: .blue,   row: 0, col: 2),
            DiagramNode(id: "view",       label: "View",         sublabel: "Presentation", color: .teal,   row: 0, col: 3),
        ],
        diagramEdges: [
            DiagramEdge(fromNode: "viewmodel",  toNode: "usecase",    label: "calls",      isBidirectional: false),
            DiagramEdge(fromNode: "usecase",    toNode: "entity",     label: "uses",       isBidirectional: false),
            DiagramEdge(fromNode: "usecase",    toNode: "repository", label: "protocol",   isBidirectional: false),
            DiagramEdge(fromNode: "view",       toNode: "viewmodel",  label: "$ binding",  isBidirectional: true),
        ]
    )

    // ─────────────────────────────── TCA ───────────────────────────────
    static let tca = ArchPattern(
        id: "tca",
        name: "Unidirectional / TCA-inspired",
        acronym: "TCA",
        tagline: "Single source of truth. State + Action + Reducer. Inspired by The Composable Architecture.",
        icon: "arrow.trianglehead.clockwise",
        color: .green,
        layers: [
            PatternLayer(name: "State",   role: "Immutable snapshot of all UI state. Single source of truth.", color: .green),
            PatternLayer(name: "Action",  role: "Exhaustive enum. Every possible event is a case.", color: .orange),
            PatternLayer(name: "Reducer", role: "Pure function: (inout State, Action) → Void. No side effects.", color: .purple),
            PatternLayer(name: "Store",   role: "Holds State. Processes Actions through Reducer. Published for SwiftUI.", color: .blue),
        ],
        keyPrinciples: [
            "State is the single source of truth",
            "State changes ONLY via the Reducer",
            "Reducer is a pure function — fully deterministic",
            "View only reads State and sends Actions",
            "Actions are explicit — every UI event is captured"
        ],
        pros: [
            "Predictable: same Action always produces same State change",
            "Time-travel debugging (replay Actions to reproduce bugs)",
            "State is easily serialised for testing",
            "Action log shows exactly what happened"
        ],
        cons: [
            "More boilerplate for simple screens",
            "Learning curve around pure functions and immutability",
            "Large State structs for complex screens"
        ],
        useCases: ["Apps requiring strong testability", "Complex multi-step flows", "Teams using functional programming"],
        files: [
            CodeFile(filename: "TCATaskFeature.swift", layerName: "State / Action / Reducer", layerColor: .purple, code: tcaFeatureCode),
            CodeFile(filename: "TCADemoView.swift",    layerName: "View / Store",              layerColor: .blue,   code: tcaViewCode),
        ],
        diagramNodes: [
            DiagramNode(id: "view",    label: "View",    sublabel: "reads State",    color: .blue,   row: 0, col: 0),
            DiagramNode(id: "action",  label: "Action",  sublabel: "send(_:)",       color: .orange, row: 0, col: 2),
            DiagramNode(id: "reducer", label: "Reducer", sublabel: "pure function",  color: .purple, row: 1, col: 2),
            DiagramNode(id: "state",   label: "State",   sublabel: "@Published",     color: .green,  row: 1, col: 0),
        ],
        diagramEdges: [
            DiagramEdge(fromNode: "view",    toNode: "action",  label: "send action",   isBidirectional: false),
            DiagramEdge(fromNode: "action",  toNode: "reducer", label: "processes",     isBidirectional: false),
            DiagramEdge(fromNode: "reducer", toNode: "state",   label: "mutates",       isBidirectional: false),
            DiagramEdge(fromNode: "state",   toNode: "view",    label: "@Published",    isBidirectional: false),
        ]
    )
}

// ─────────────────────────────────────────────────────────────────
// Code snippets (educational excerpts, key parts highlighted)
// ─────────────────────────────────────────────────────────────────

// MARK: - MVC Snippets
private let mvcModelCode = """
import Foundation

// MVC – Model: pure data, no UI dependencies
struct MVCTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}

class MVCTaskModel {
    private(set) var tasks: [MVCTask] = []

    func addTask(title: String) {
        tasks.append(MVCTask(id: UUID(), title: title, isCompleted: false))
    }

    func toggleTask(id: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            tasks[index].isCompleted.toggle()
        }
    }
}
"""

private let mvcControllerCode = """
import Foundation
import Combine

// MVC – Controller: mediates between Model and View
// In iOS, this is typically a UIViewController subclass.
// The "Massive View Controller" anti-pattern grows here.
class MVCTaskController: ObservableObject {
    @Published private(set) var tasks: [MVCTask] = []
    private let model = MVCTaskModel()

    func userDidRequestAddTask(title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        model.addTask(title: title)
        tasks = model.tasks   // sync View-facing state from Model
    }

    func userDidToggleTask(id: UUID) {
        model.toggleTask(id: id)
        tasks = model.tasks
    }
}
"""

private let mvcViewCode = """
import SwiftUI

// MVC – View: renders data, calls Controller on user events
// View has a DIRECT reference to Controller — key MVC characteristic
struct MVCDemoView: View {
    @StateObject private var controller = MVCTaskController()
    @State private var newTaskTitle = ""

    var body: some View {
        VStack {
            HStack {
                TextField("New task…", text: $newTaskTitle)
                Button("Add") {
                    // View calls Controller directly
                    controller.userDidRequestAddTask(title: newTaskTitle)
                    newTaskTitle = ""
                }
            }
            List(controller.tasks) { task in
                Text(task.title).strikethrough(task.isCompleted)
                    .onTapGesture { controller.userDidToggleTask(id: task.id) }
            }
        }
    }
}
"""

// MARK: - MVP Snippets
private let mvpModelCode = """
import Foundation

// MVP – Model: plain data
struct MVPTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}

class MVPTaskStore {
    private(set) var tasks: [MVPTask] = []

    func add(title: String) {
        tasks.append(MVPTask(id: UUID(), title: title, isCompleted: false))
    }

    func toggle(id: UUID) {
        if let i = tasks.firstIndex(where: { $0.id == id }) {
            tasks[i].isCompleted.toggle()
        }
    }
}
"""

private let mvpPresenterCode = """
import Foundation

// MVP – Presenter: ALL logic lives here
// Key: Presenter does NOT import UIKit or SwiftUI
// Communication with View is via protocol only

protocol MVPTaskViewProtocol: AnyObject {
    func displayTasks(_ tasks: [MVPTask])
    func displayError(_ message: String)
}

class MVPTaskPresenter: ObservableObject {
    @Published private(set) var tasks: [MVPTask] = []
    @Published var errorMessage: String?

    // Weak ref prevents retain cycle (Presenter ↔ View)
    weak var view: MVPTaskViewProtocol?

    private let store = MVPTaskStore()

    func addTask(title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Title cannot be empty."
            view?.displayError("Title cannot be empty.")
            return
        }
        store.add(title: title)
        tasks = store.tasks
        view?.displayTasks(tasks)
    }
}
"""

private let mvpViewCode = """
import SwiftUI

// MVP – View: PASSIVE — only renders, delegates to Presenter
// No logic here. Even validation lives in the Presenter.
struct MVPDemoView: View, MVPTaskViewProtocol {
    @StateObject private var presenter = MVPTaskPresenter()
    @State private var newTaskTitle = ""

    var body: some View {
        VStack {
            HStack {
                TextField("New task…", text: $newTaskTitle)
                Button("Add") {
                    // View delegates to Presenter — no logic here
                    presenter.addTask(title: newTaskTitle)
                    if presenter.errorMessage == nil { newTaskTitle = "" }
                }
            }
            List(presenter.tasks) { task in
                Text(task.title)
                    .onTapGesture { presenter.toggleTask(id: task.id) }
            }
        }
        .onAppear { presenter.view = self }  // register as delegate
    }

    // Passive protocol conformance
    func displayTasks(_ tasks: [MVPTask]) { /* handled by @Published */ }
    func displayError(_ message: String)  { /* handled by @Published */ }
}
"""

// MARK: - MVVM Snippets
private let mvvmModelCode = """
import Foundation

// MVVM – Model: plain value type
struct MVVMTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}
"""

private let mvvmViewModelCode = """
import Foundation
import Combine

// MVVM – ViewModel: exposes reactive state via @Published
// Key: zero UIKit/SwiftUI imports — fully unit testable
final class MVVMTaskViewModel: ObservableObject {
    // Outputs — View observes these
    @Published private(set) var tasks: [MVVMTask] = []
    @Published private(set) var completedCount: Int = 0

    // Input — View binds TextField to this
    @Published var newTaskTitle: String = ""

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Reactive pipeline: derive completedCount from tasks
        $tasks
            .map { $0.filter(\\.isCompleted).count }
            .assign(to: &$completedCount)
    }

    func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        tasks.append(MVVMTask(id: UUID(), title: trimmed, isCompleted: false))
        newTaskTitle = ""
    }

    func toggleTask(_ task: MVVMTask) {
        if let i = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[i].isCompleted.toggle()
        }
    }
}
"""

private let mvvmViewCode = """
import SwiftUI

// MVVM – View: binds to ViewModel with @StateObject and $
// Zero business logic — pure rendering function of ViewModel state
struct MVVMDemoView: View {
    @StateObject private var viewModel = MVVMTaskViewModel()

    var body: some View {
        VStack {
            // Stats powered by Combine-derived @Published
            Text("\\(viewModel.completedCount) of \\(viewModel.tasks.count) done")

            HStack {
                // Two-way binding — TextField updates viewModel.newTaskTitle
                TextField("New task…", text: $viewModel.newTaskTitle)
                Button("Add") { viewModel.addTask() }
            }

            List(viewModel.tasks) { task in
                Text(task.title).strikethrough(task.isCompleted)
                    .onTapGesture { viewModel.toggleTask(task) }
            }
        }
    }
}
"""

// MARK: - VIPER Snippets
private let viperEntityCode = """
import Foundation

// VIPER – Entity: pure data, no logic
// Only the Interactor may create or mutate Entities
struct VIPERTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}
"""

private let viperInteractorCode = """
import Foundation

// VIPER – Interactor: ALL business logic
// Receives requests from Presenter (Input protocol)
// Returns results to Presenter (Output protocol)
// Never imports UIKit or SwiftUI

protocol VIPERTaskInteractorInputProtocol: AnyObject {
    func fetchTasks()
    func addTask(title: String)
    func toggleTask(id: UUID)
}

protocol VIPERTaskInteractorOutputProtocol: AnyObject {
    func didFetchTasks(_ tasks: [VIPERTask])
    func didFailWithError(_ message: String)
}

final class VIPERTaskInteractor: VIPERTaskInteractorInputProtocol {
    weak var output: VIPERTaskInteractorOutputProtocol?
    private var tasks: [VIPERTask] = []

    func fetchTasks() {
        output?.didFetchTasks(tasks)
    }

    func addTask(title: String) {
        guard !title.isEmpty else {
            output?.didFailWithError("Title cannot be empty.")
            return
        }
        tasks.append(VIPERTask(id: UUID(), title: title, isCompleted: false))
        output?.didFetchTasks(tasks)
    }

    func toggleTask(id: UUID) {
        if let i = tasks.firstIndex(where: { $0.id == id }) {
            tasks[i].isCompleted.toggle()
        }
        output?.didFetchTasks(tasks)
    }
}
"""

private let viperPresenterCode = """
import Foundation
import Combine

// VIPER – Presenter: formats data for display
// Bridges View ↔ Interactor
// Conforms to BOTH Interactor output AND View input protocols

final class VIPERTaskPresenter: ObservableObject,
    VIPERTaskInteractorOutputProtocol {

    @Published private(set) var tasks: [VIPERTask] = []
    @Published var errorMessage: String?

    var interactor: VIPERTaskInteractorInputProtocol?
    var router: VIPERTaskRouterProtocol?

    func viewDidLoad() { interactor?.fetchTasks() }
    func didTapAddTask(title: String) { interactor?.addTask(title: title) }
    func didTapToggleTask(id: UUID) { interactor?.toggleTask(id: id) }

    // From Interactor
    func didFetchTasks(_ tasks: [VIPERTask]) {
        DispatchQueue.main.async { self.tasks = tasks }
    }
    func didFailWithError(_ message: String) {
        DispatchQueue.main.async { self.errorMessage = message }
    }
}
"""

private let viperRouterCode = """
import SwiftUI

// VIPER – Router: navigation + module assembly
// The ONLY class that knows about all five VIPER components
// Creates, wires, and returns the entry view

protocol VIPERTaskRouterProtocol: AnyObject {
    func navigateToDetail(task: VIPERTask, from view: AnyView)
}

final class VIPERTaskRouter: VIPERTaskRouterProtocol {
    func navigateToDetail(task: VIPERTask, from view: AnyView) {
        // Push detail view onto navigation stack
    }
}

// Module Assembler — the only place components are wired
final class VIPERTaskAssembler: ObservableObject {
    let presenter = VIPERTaskPresenter()

    init() {
        let interactor = VIPERTaskInteractor()
        let router = VIPERTaskRouter()

        presenter.interactor = interactor
        presenter.router     = router
        interactor.output    = presenter   // back-reference
    }
}
"""

private let viperViewCode = """
import SwiftUI

// VIPER – View: COMPLETELY PASSIVE
// No logic — only renders and routes events to Presenter
struct VIPERDemoView: View {
    @StateObject private var assembler = VIPERTaskAssembler()
    @State private var newTaskTitle = ""

    private var presenter: VIPERTaskPresenter { assembler.presenter }

    var body: some View {
        List(presenter.tasks) { task in
            Text(task.title)
                .onTapGesture {
                    // View sends event to Presenter — no logic here
                    presenter.didTapToggleTask(id: task.id)
                }
        }
        .onAppear { presenter.viewDidLoad() }
        // Add task bar etc.
    }
}
"""

// MARK: - Clean Architecture Snippets
private let cleanEntityCode = """
import Foundation

// Clean Architecture – Domain Entity
// Innermost circle. Zero framework dependencies.
struct CleanTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}

// Domain errors — no external dependencies
enum CleanTaskError: LocalizedError {
    case emptyTitle
    case taskNotFound

    var errorDescription: String? {
        switch self {
        case .emptyTitle:   return "Task title cannot be empty."
        case .taskNotFound: return "Task not found."
        }
    }
}
"""

private let cleanUseCaseCode = """
import Foundation

// Clean Architecture – Repository Protocol (defined in Domain)
// Data layer IMPLEMENTS this. Domain never depends on Data.
// This is the Dependency Inversion Principle in action.
protocol CleanTaskRepositoryProtocol {
    func fetchAll() -> [CleanTask]
    func add(title: String) throws -> CleanTask
    func toggle(id: UUID) throws -> CleanTask
    func delete(id: UUID)
}

// Each Use Case = one application action
final class AddTaskUseCase {
    private let repository: CleanTaskRepositoryProtocol
    init(repository: CleanTaskRepositoryProtocol) { self.repository = repository }

    func execute(title: String) throws -> CleanTask {
        try repository.add(title: title)
    }
}

final class FetchTasksUseCase {
    private let repository: CleanTaskRepositoryProtocol
    init(repository: CleanTaskRepositoryProtocol) { self.repository = repository }

    func execute() -> [CleanTask] { repository.fetchAll() }
}
"""

private let cleanRepositoryCode = """
import Foundation

// Clean Architecture – Repository (Data Layer)
// Implements the Domain protocol. Knows about CoreData/API/etc.
// Domain is completely unaware this class exists.
final class CleanTaskRepository: CleanTaskRepositoryProtocol {
    private var tasks: [CleanTask] = []

    func fetchAll() -> [CleanTask] { tasks }

    func add(title: String) throws -> CleanTask {
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { throw CleanTaskError.emptyTitle }
        let task = CleanTask(id: UUID(), title: trimmed, isCompleted: false)
        tasks.append(task)
        return task
    }

    func toggle(id: UUID) throws -> CleanTask {
        guard let i = tasks.firstIndex(where: { $0.id == id })
        else { throw CleanTaskError.taskNotFound }
        tasks[i].isCompleted.toggle()
        return tasks[i]
    }

    func delete(id: UUID) {
        tasks.removeAll(where: { $0.id == id })
    }
}
"""

private let cleanViewModelCode = """
import Foundation
import Combine

// Clean Architecture – ViewModel (Presentation Layer)
// Depends on Domain Use Cases — NOT on the concrete Repository
// Dependency is injected, so tests can inject a mock repository
final class CleanTaskViewModel: ObservableObject {
    @Published private(set) var tasks: [CleanTask] = []
    @Published var errorMessage: String?

    private let fetchUseCase:  FetchTasksUseCase
    private let addUseCase:    AddTaskUseCase

    // Default init injects the real repository
    init(repository: CleanTaskRepositoryProtocol = CleanTaskRepository()) {
        fetchUseCase = FetchTasksUseCase(repository: repository)
        addUseCase   = AddTaskUseCase(repository: repository)
        loadTasks()
    }

    func addTask(title: String) {
        do {
            _ = try addUseCase.execute(title: title)
            loadTasks()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadTasks() {
        tasks = fetchUseCase.execute()
    }
}
"""

// MARK: - TCA Snippets
private let tcaFeatureCode = """
import Foundation

// TCA-Inspired – State + Action + Reducer

// State: single source of truth
struct TCATaskState: Equatable {
    var tasks: [TCATask]      = []
    var newTaskTitle: String  = ""
    var errorMessage: String? = nil
}

// Action: exhaustive enum — every possible event
enum TCATaskAction {
    case newTitleChanged(String)
    case addButtonTapped
    case taskToggled(id: UUID)
    case taskDeleted(id: UUID)
}

// Reducer: pure function — same inputs always give same output
struct TCATaskReducer {
    func reduce(state: inout TCATaskState, action: TCATaskAction) {
        switch action {
        case .newTitleChanged(let title):
            state.newTaskTitle = title           // only state change

        case .addButtonTapped:
            let trimmed = state.newTaskTitle.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else {
                state.errorMessage = "Title cannot be empty."
                return
            }
            state.tasks.append(TCATask(id: UUID(), title: trimmed))
            state.newTaskTitle = ""

        case .taskToggled(let id):
            if let i = state.tasks.firstIndex(where: { $0.id == id }) {
                state.tasks[i].isCompleted.toggle()
            }

        case .taskDeleted(let id):
            state.tasks.removeAll(where: { $0.id == id })
        }
    }
}

// Store: holds State, routes Actions through Reducer
final class TCATaskStore: ObservableObject {
    @Published private(set) var state = TCATaskState()
    private let reducer = TCATaskReducer()

    func send(_ action: TCATaskAction) {
        reducer.reduce(state: &state, action: action)
    }
}
"""

private let tcaViewCode = """
import SwiftUI

// TCA – View: only reads State and sends Actions
// NO logic — a pure rendering function of Store.state
struct TCADemoView: View {
    @StateObject private var store = TCATaskStore()

    var body: some View {
        VStack {
            HStack {
                // TextField bound to State via Binding(get:set:)
                // set fires an Action — never mutates directly
                TextField("New task…", text: Binding(
                    get: { store.state.newTaskTitle },
                    set: { store.send(.newTitleChanged($0)) }
                ))

                Button("Add") {
                    store.send(.addButtonTapped)   // the only way to add
                }
            }

            List(store.state.tasks) { task in
                Text(task.title)
                    .onTapGesture {
                        store.send(.taskToggled(id: task.id))
                    }
            }
        }
    }
}
"""
