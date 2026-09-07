import SwiftUI

// ──────────────────────────────────────────────────────────────────
// All Interview Topics with explanations, code snippets, and quizzes
// ──────────────────────────────────────────────────────────────────
struct InterviewTopicsLibrary {
    static let all: [InterviewTopic] = [
        memoryManagement,
        concurrency,
        combine,
        swiftUIvsUIKit,
        dependencyInjection,
        designPatterns,
        networking,
        coreData,
        testing,
        swiftFundamentals
    ]

    // ──────────────────── 1. Memory Management ────────────────────
    static let memoryManagement = InterviewTopic(
        id: "memory",
        title: "Memory Management",
        subtitle: "ARC, retain cycles, weak & unowned",
        icon: "memorychip",
        color: .blue,
        difficulty: .intermediate,
        overview: "Swift uses Automatic Reference Counting (ARC) to manage memory. Understanding ARC is critical for avoiding memory leaks and crashes in iOS apps. The most common pitfall is a retain cycle, where two objects hold strong references to each other — preventing either from being deallocated.",
        keyConcepts: [
            KeyConcept(term: "ARC", explanation: "Swift automatically tracks and manages memory. When a class instance's reference count drops to 0, it is deallocated. ARC inserts retain/release calls at compile time."),
            KeyConcept(term: "Strong Reference", explanation: "Default. Increases reference count by 1. The default for all class references."),
            KeyConcept(term: "weak", explanation: "Does NOT increase reference count. Automatically becomes nil when the referenced object is deallocated. Must be Optional. Use for delegate references."),
            KeyConcept(term: "unowned", explanation: "Does NOT increase reference count. Does NOT become nil (unsafe if accessed after dealloc). Use when both objects have the same lifetime."),
            KeyConcept(term: "Retain Cycle", explanation: "When two objects hold strong references to each other. Neither can be deallocated. Common between View and Delegate, or in closures that capture self strongly."),
            KeyConcept(term: "Capture List", explanation: "[weak self] or [unowned self] in closure definitions prevents closures from strongly capturing self."),
        ],
        codeSnippets: [
            CodeSnippet(
                title: "Retain Cycle Example",
                description: "A retain cycle between two classes — neither gets deallocated.",
                code: """
class Person {
    var name: String
    var apartment: Apartment?   // strong — causes cycle!
    init(name: String) { self.name = name }
    deinit { print("\\(name) is deallocated") }
}

class Apartment {
    var tenant: Person?         // strong — causes cycle!
    deinit { print("Apartment is deallocated") }
}

var john: Person? = Person(name: "John")
var apt: Apartment? = Apartment()
john?.apartment = apt
apt?.tenant = john

john = nil   // deinit NOT called — retain cycle!
apt  = nil   // deinit NOT called — memory leak!
""",
                language: "swift"
            ),
            CodeSnippet(
                title: "Fix with weak",
                description: "Break the retain cycle by marking one reference weak.",
                code: """
class Apartment {
    weak var tenant: Person?    // weak — breaks the cycle
    deinit { print("Apartment is deallocated") }
}

// Now:
john = nil   // deinit IS called — "John is deallocated"
apt  = nil   // deinit IS called — "Apartment is deallocated"
""",
                language: "swift"
            ),
            CodeSnippet(
                title: "Capture List in Closures",
                description: "Preventing retain cycles in async closures.",
                code: """
class ViewController {
    var name = "My VC"

    func loadData() {
        // Without [weak self] — retain cycle!
        // URLSession.shared.dataTask { data, _, _ in
        //     print(self.name)   // self captured strongly
        // }

        // Correct: use [weak self]
        URLSession.shared.dataTask(with: URL(string: "...")!) { [weak self] data, _, _ in
            guard let self else { return }   // safely unwrap
            print(self.name)
        }.resume()
    }

    deinit { print("ViewController deallocated") }
}
""",
                language: "swift"
            ),
        ],
        quiz: [
            QuizQuestion(
                question: "What does ARC stand for?",
                options: ["Automatic Reference Counting", "Automatic Resource Control", "Asynchronous Reference Cycle", "Apple Runtime Core"],
                correctIndex: 0,
                explanation: "ARC stands for Automatic Reference Counting. Swift uses it to automatically manage memory allocation and deallocation."
            ),
            QuizQuestion(
                question: "What is the key difference between `weak` and `unowned`?",
                options: [
                    "`weak` can be nil, `unowned` cannot",
                    "`weak` is faster, `unowned` is safer",
                    "`weak` is for structs, `unowned` for classes",
                    "There is no practical difference"
                ],
                correctIndex: 0,
                explanation: "`weak` references become Optional (nil) when the referenced object is deallocated. `unowned` assumes the object is still alive — accessing it after dealloc crashes your app."
            ),
            QuizQuestion(
                question: "Which closure capture list prevents a retain cycle?",
                options: [
                    "[weak self] or [unowned self]",
                    "[strong self]",
                    "[copy self]",
                    "[lazy self]"
                ],
                correctIndex: 0,
                explanation: "Using `[weak self]` or `[unowned self]` in a capture list prevents the closure from strongly capturing `self`, breaking the retain cycle."
            ),
        ]
    )

    // ──────────────────── 2. Concurrency ────────────────────
    static let concurrency = InterviewTopic(
        id: "concurrency",
        title: "Concurrency",
        subtitle: "GCD, async/await, Actors, Tasks",
        icon: "cpu",
        color: .orange,
        difficulty: .advanced,
        overview: "iOS apps must perform work off the main thread to stay responsive. Swift 5.5 introduced structured concurrency (async/await, Task, Actor) as a modern alternative to GCD. Understanding both is essential for interviews.",
        keyConcepts: [
            KeyConcept(term: "Main Thread", explanation: "All UI updates must happen on the main thread. Blocking it causes jank or the spinning beach ball."),
            KeyConcept(term: "GCD (DispatchQueue)", explanation: "Grand Central Dispatch. Low-level C API. Use .global() for background work, .main for UI updates."),
            KeyConcept(term: "async/await", explanation: "Swift 5.5+. Suspends the current task without blocking a thread. Makes async code read like synchronous code."),
            KeyConcept(term: "Task", explanation: "Creates a unit of asynchronous work in Swift Concurrency. Can be cancelled."),
            KeyConcept(term: "Actor", explanation: "A reference type that protects its mutable state from concurrent access. Only one caller can access actor state at a time."),
            KeyConcept(term: "@MainActor", explanation: "Ensures a function or class always runs on the main thread. Replaces DispatchQueue.main.async in many cases."),
        ],
        codeSnippets: [
            CodeSnippet(
                title: "GCD — Classic Approach",
                description: "Fetch data on background queue, update UI on main queue.",
                code: """
// Classic GCD pattern
func fetchUserProfile(userID: String) {
    DispatchQueue.global(qos: .userInitiated).async {
        // Simulated network call on background thread
        let data = NetworkService.fetchUser(id: userID)

        DispatchQueue.main.async {
            // Must jump back to main thread for UI
            self.nameLabel.text = data.name
        }
    }
}
""",
                language: "swift"
            ),
            CodeSnippet(
                title: "async/await — Modern Approach",
                description: "Same operation with structured concurrency. Cleaner, safer.",
                code: """
// Modern async/await — Swift 5.5+
@MainActor
func fetchUserProfile(userID: String) async {
    do {
        // Suspends here — doesn't block a thread
        let user = try await NetworkService.fetchUser(id: userID)

        // @MainActor guarantees we're on the main thread
        nameLabel.text = user.name
    } catch {
        showError(error)
    }
}

// Call from SwiftUI button
Button("Load") {
    Task { await fetchUserProfile(userID: "123") }
}
""",
                language: "swift"
            ),
            CodeSnippet(
                title: "Actor — Thread-Safe State",
                description: "An Actor protects mutable state from data races.",
                code: """
// Actor: only one task can access its state at a time
actor TaskCache {
    private var cache: [String: String] = [:]

    func get(key: String) -> String? {
        cache[key]
    }

    func set(key: String, value: String) {
        cache[key] = value
    }
}

let cache = TaskCache()

// Must use await to access actor-isolated state
Task {
    await cache.set(key: "user", value: "Alice")
    let name = await cache.get(key: "user")
    print(name ?? "not found")
}
""",
                language: "swift"
            ),
        ],
        quiz: [
            QuizQuestion(
                question: "What does `DispatchQueue.main.async` do?",
                options: [
                    "Schedules a closure to run on the main thread asynchronously",
                    "Runs a closure immediately on the main thread",
                    "Creates a new background thread",
                    "Suspends the current Task"
                ],
                correctIndex: 0,
                explanation: "`DispatchQueue.main.async` enqueues the closure to run on the main (UI) thread asynchronously — it returns immediately and the closure runs later."
            ),
            QuizQuestion(
                question: "What is an `Actor` in Swift Concurrency?",
                options: [
                    "A reference type that protects mutable state from concurrent access",
                    "A struct that runs on a background thread",
                    "A replacement for DispatchQueue",
                    "A class that conforms to async protocol"
                ],
                correctIndex: 0,
                explanation: "An Actor is a reference type that serialises access to its mutable state, preventing data races without manual locking."
            ),
            QuizQuestion(
                question: "What does `await` do in an async function?",
                options: [
                    "Suspends the current task without blocking a thread",
                    "Blocks the current thread until the async call completes",
                    "Creates a new background thread",
                    "Cancels pending tasks"
                ],
                correctIndex: 0,
                explanation: "`await` marks a suspension point. The current task is suspended and the thread is freed for other work. Execution resumes when the awaited operation completes."
            ),
        ]
    )

    // ──────────────────── 3. Combine ────────────────────
    static let combine = InterviewTopic(
        id: "combine",
        title: "Combine Framework",
        subtitle: "Publishers, Subscribers, Operators",
        icon: "arrow.triangle.merge",
        color: .purple,
        difficulty: .intermediate,
        overview: "Combine is Apple's reactive programming framework. It provides a declarative Swift API for processing asynchronous events over time. It is the backbone of MVVM in UIKit and works alongside SwiftUI's state management.",
        keyConcepts: [
            KeyConcept(term: "Publisher", explanation: "Emits a sequence of values over time. Examples: URLSession.DataTaskPublisher, @Published, Just, PassthroughSubject."),
            KeyConcept(term: "Subscriber", explanation: "Receives values from a Publisher. sink and assign are the two built-in subscribers."),
            KeyConcept(term: "Operator", explanation: "Transforms values between Publisher and Subscriber. Examples: map, filter, flatMap, combineLatest, debounce."),
            KeyConcept(term: "AnyCancellable", explanation: "A token returned by sink/assign. Stores it in a Set<AnyCancellable> to keep the subscription alive."),
            KeyConcept(term: "@Published", explanation: "Property wrapper that creates a Publisher from a property. Used in ObservableObject ViewModels."),
            KeyConcept(term: "PassthroughSubject", explanation: "A Publisher you can send values into manually. Useful for bridging non-Combine code."),
        ],
        codeSnippets: [
            CodeSnippet(
                title: "Basic Publisher Chain",
                description: "Map and filter operators transforming values.",
                code: """
import Combine

var cancellables = Set<AnyCancellable>()

// Publisher → operator chain → subscriber
[1, 2, 3, 4, 5].publisher
    .filter { $0 % 2 == 0 }       // keep even numbers
    .map { $0 * 10 }              // multiply by 10
    .sink { value in
        print(value)              // prints: 20, 40
    }
    .store(in: &cancellables)
""",
                language: "swift"
            ),
            CodeSnippet(
                title: "@Published + Combine Pipeline in ViewModel",
                description: "Reactive derived state using assign(to:).",
                code: """
import Combine
import Foundation

class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var results: [String] = []
    @Published private(set) var isSearching: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchText
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .filter { !$0.isEmpty }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isSearching = true
            })
            .flatMap { query in
                SearchService.search(query: query)
                    .replaceError(with: [])
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isSearching = false
            })
            .assign(to: &$results)
    }
}
""",
                language: "swift"
            ),
        ],
        quiz: [
            QuizQuestion(
                question: "What does `sink` do in Combine?",
                options: [
                    "Subscribes to a Publisher and executes a closure for each value",
                    "Creates a new Publisher from a value",
                    "Cancels a subscription",
                    "Transforms values between publishers"
                ],
                correctIndex: 0,
                explanation: "`sink` is a subscriber that attaches a closure to receive values (and completion) from a Publisher. It returns an `AnyCancellable`."
            ),
            QuizQuestion(
                question: "Why do you store subscriptions in `Set<AnyCancellable>`?",
                options: [
                    "To keep the subscription alive until the store is deallocated",
                    "To avoid duplicate subscriptions",
                    "To run subscriptions concurrently",
                    "To convert them to async/await"
                ],
                correctIndex: 0,
                explanation: "`AnyCancellable` cancels the subscription when it is deallocated. Storing it in a Set (typically on the ViewModel) keeps the subscription alive as long as the ViewModel lives."
            ),
            QuizQuestion(
                question: "Which operator waits for multiple Publishers to emit before combining?",
                options: ["combineLatest", "merge", "zip", "flatMap"],
                correctIndex: 0,
                explanation: "`combineLatest` emits whenever ANY of its upstream publishers emits, combining them into a tuple. `zip` pairs emissions one-to-one."
            ),
        ]
    )

    // ──────────────────── 4. SwiftUI vs UIKit ────────────────────
    static let swiftUIvsUIKit = InterviewTopic(
        id: "swiftuivsUIKit",
        title: "SwiftUI vs UIKit",
        subtitle: "Lifecycle, state management, interop",
        icon: "iphone",
        color: .teal,
        difficulty: .intermediate,
        overview: "Understanding both frameworks and when to use each is important for senior iOS interviews. SwiftUI is declarative and state-driven. UIKit is imperative with explicit lifecycle. Most production apps use both.",
        keyConcepts: [
            KeyConcept(term: "Declarative vs Imperative", explanation: "SwiftUI: describe WHAT the UI should look like for a given state. UIKit: explicitly tell the system HOW to update the UI (set text, reload table, etc.)."),
            KeyConcept(term: "SwiftUI State", explanation: "@State, @Binding, @StateObject, @ObservedObject, @EnvironmentObject. All trigger view re-renders on change."),
            KeyConcept(term: "UIViewController Lifecycle", explanation: "viewDidLoad → viewWillAppear → viewDidAppear → viewWillDisappear → viewDidDisappear → deinit."),
            KeyConcept(term: "UIViewRepresentable", explanation: "Bridge UIKit views into SwiftUI. Use when SwiftUI lacks a needed component (e.g., UITextView, MKMapView, WKWebView)."),
            KeyConcept(term: "UIHostingController", explanation: "Bridge SwiftUI views into UIKit. Wraps a SwiftUI View in a UIViewController."),
        ],
        codeSnippets: [
            CodeSnippet(
                title: "UIKit Counter (Imperative)",
                description: "Manual UI update every time state changes.",
                code: """
// UIKit — imperative: you tell the system HOW to update
class CounterViewController: UIViewController {
    var count = 0
    let label = UILabel()
    let button = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        button.setTitle("Tap me", for: .normal)
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        // Layout code omitted...
    }

    @objc func tapped() {
        count += 1
        label.text = "Count: \\(count)"   // must manually update UI
    }
}
""",
                language: "swift"
            ),
            CodeSnippet(
                title: "SwiftUI Counter (Declarative)",
                description: "State change automatically re-renders the view.",
                code: """
// SwiftUI — declarative: describe WHAT the UI looks like
struct CounterView: View {
    @State private var count = 0

    var body: some View {
        VStack {
            Text("Count: \\(count)")
                .font(.title)
            Button("Tap me") {
                count += 1   // State change triggers re-render automatically
            }
        }
    }
}
""",
                language: "swift"
            ),
            CodeSnippet(
                title: "UIViewRepresentable — Wrap UITextView in SwiftUI",
                description: "Bridging UIKit into SwiftUI for components SwiftUI lacks.",
                code: """
struct TextView: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.delegate = context.coordinator
        return tv
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        @Binding var text: String
        init(text: Binding<String>) { _text = text }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
        }
    }
}
""",
                language: "swift"
            ),
        ],
        quiz: [
            QuizQuestion(
                question: "What does `@State` do in SwiftUI?",
                options: [
                    "Creates a local, mutable state that triggers view re-renders on change",
                    "Passes state down from a parent view",
                    "Observes an external ObservableObject",
                    "Persists state to UserDefaults"
                ],
                correctIndex: 0,
                explanation: "`@State` creates a local source of truth for a view. When the value changes, SwiftUI re-renders the view body."
            ),
            QuizQuestion(
                question: "Which class bridges SwiftUI views into a UIKit app?",
                options: ["UIHostingController", "UIViewRepresentable", "UIViewControllerRepresentable", "SwiftUIBridge"],
                correctIndex: 0,
                explanation: "`UIHostingController` is a `UIViewController` subclass that hosts a SwiftUI `View`. Use it to embed SwiftUI in a UIKit navigation stack."
            ),
            QuizQuestion(
                question: "In UIKit, which lifecycle method is called ONCE when the view is loaded from the nib/storyboard?",
                options: ["viewDidLoad", "viewWillAppear", "viewDidAppear", "loadView"],
                correctIndex: 0,
                explanation: "`viewDidLoad` is called once after the view is loaded into memory. It's the standard place for one-time setup. `viewWillAppear` is called every time the view becomes visible."
            ),
        ]
    )

    // ──────────────────── 5. Dependency Injection ────────────────────
    static let dependencyInjection = InterviewTopic(
        id: "di",
        title: "Dependency Injection",
        subtitle: "Constructor, property, container DI",
        icon: "arrow.triangle.swap",
        color: .indigo,
        difficulty: .intermediate,
        overview: "Dependency Injection (DI) is the practice of providing a class's dependencies from the outside rather than creating them internally. It makes code testable, flexible, and loosely coupled.",
        keyConcepts: [
            KeyConcept(term: "Constructor Injection", explanation: "Dependencies passed via init(). Most common and recommended. Makes dependencies explicit and required."),
            KeyConcept(term: "Property Injection", explanation: "Dependencies assigned via a property after initialisation. More flexible but dependency can be nil."),
            KeyConcept(term: "Method Injection", explanation: "Dependencies passed into a specific method. Used when the dependency is only needed for one operation."),
            KeyConcept(term: "DI Container", explanation: "A registry that resolves dependencies automatically. Examples: Swinject, Factory, Resolver. Useful in large apps."),
            KeyConcept(term: "Protocol-based DI", explanation: "Inject a protocol, not a concrete type. Allows swapping real and mock implementations for testing."),
        ],
        codeSnippets: [
            CodeSnippet(
                title: "Constructor Injection (Recommended)",
                description: "Dependency injected via init — explicit and testable.",
                code: """
// Protocol makes the service swappable
protocol NetworkServiceProtocol {
    func fetchUsers() async throws -> [User]
}

// Real implementation
class NetworkService: NetworkServiceProtocol { ... }

// Mock for tests
class MockNetworkService: NetworkServiceProtocol {
    func fetchUsers() async throws -> [User] {
        return [User(name: "Test User")]
    }
}

// ViewModel receives the dependency via init — NOT creating it
class UserListViewModel: ObservableObject {
    @Published private(set) var users: [User] = []
    private let service: NetworkServiceProtocol

    // Dependency injected here — easy to test!
    init(service: NetworkServiceProtocol = NetworkService()) {
        self.service = service
    }

    func loadUsers() async {
        users = (try? await service.fetchUsers()) ?? []
    }
}

// In tests:
let vm = UserListViewModel(service: MockNetworkService())
// In production (default):
let vm = UserListViewModel()
""",
                language: "swift"
            ),
        ],
        quiz: [
            QuizQuestion(
                question: "What is the main benefit of Dependency Injection?",
                options: [
                    "Makes code testable by allowing dependencies to be swapped with mocks",
                    "Makes apps run faster",
                    "Reduces the number of classes needed",
                    "Automatically manages memory"
                ],
                correctIndex: 0,
                explanation: "DI allows you to inject mock dependencies in tests and real implementations in production — without changing the class under test."
            ),
            QuizQuestion(
                question: "Which form of DI makes dependencies explicit and required at init?",
                options: ["Constructor Injection", "Property Injection", "Method Injection", "Container Injection"],
                correctIndex: 0,
                explanation: "Constructor (initializer) injection passes all required dependencies through `init()`. The compiler enforces that they're always provided."
            ),
            QuizQuestion(
                question: "Why inject a protocol rather than a concrete type?",
                options: [
                    "To allow different implementations (real vs mock) to be substituted",
                    "Protocols are faster than classes",
                    "Concrete types can't be injected",
                    "Protocol injection avoids retain cycles"
                ],
                correctIndex: 0,
                explanation: "Injecting a protocol instead of a concrete type decouples the caller from the implementation. Tests can inject a mock; production uses the real class."
            ),
        ]
    )

    // ──────────────────── 6. Design Patterns ────────────────────
    static let designPatterns = InterviewTopic(
        id: "patterns",
        title: "Design Patterns",
        subtitle: "Singleton, Factory, Observer, Coordinator",
        icon: "square.on.square.intersection.dashed",
        color: .pink,
        difficulty: .intermediate,
        overview: "Design patterns are reusable solutions to common programming problems. iOS interviewers frequently ask about Singleton, Factory, Observer/Delegate, and Coordinator patterns.",
        keyConcepts: [
            KeyConcept(term: "Singleton", explanation: "Ensures only one instance of a class exists. Example: URLSession.shared, UserDefaults.standard. Anti-pattern when overused."),
            KeyConcept(term: "Factory", explanation: "Provides an interface to create objects without specifying the exact class. Decouples creation from usage."),
            KeyConcept(term: "Observer (Delegate)", explanation: "Defines a one-to-many dependency. When one object changes, all its observers are notified. UITableViewDelegate is a classic example."),
            KeyConcept(term: "Coordinator", explanation: "Moves navigation logic out of ViewControllers. A Coordinator owns child coordinators and creates ViewControllers, keeping ViewControllers navigation-free."),
            KeyConcept(term: "Builder", explanation: "Separates the construction of complex objects from their representation. Used for objects with many optional parameters."),
        ],
        codeSnippets: [
            CodeSnippet(
                title: "Singleton Pattern",
                description: "Thread-safe singleton with a private initialiser.",
                code: """
// Singleton — only one instance, globally accessible
class AnalyticsService {
    static let shared = AnalyticsService()   // single instance
    private init() {}                         // prevents external init

    func track(event: String) {
        print("Tracking: \\(event)")
    }
}

// Usage
AnalyticsService.shared.track(event: "app_open")

// ⚠️ Interview note: Singletons are hard to test and create
// tight coupling. Prefer DI + protocol in testable code.
""",
                language: "swift"
            ),
            CodeSnippet(
                title: "Coordinator Pattern",
                description: "Navigation logic extracted from ViewControllers.",
                code: """
// Coordinator Protocol
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

// App Coordinator
class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let listCoordinator = TaskListCoordinator(nav: navigationController)
        childCoordinators.append(listCoordinator)
        listCoordinator.start()
    }
}

// ViewController no longer knows about navigation:
class TaskListViewController: UIViewController {
    var onTaskSelected: ((Task) -> Void)?   // delegate to Coordinator

    func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
        onTaskSelected?(tasks[ip.row])   // Coordinator handles navigation
    }
}
""",
                language: "swift"
            ),
        ],
        quiz: [
            QuizQuestion(
                question: "What problem does the Coordinator pattern solve?",
                options: [
                    "Removes navigation logic from ViewControllers",
                    "Ensures only one instance of a class",
                    "Decouples object creation from usage",
                    "Manages memory automatically"
                ],
                correctIndex: 0,
                explanation: "The Coordinator pattern extracts navigation/routing logic out of UIViewControllers, keeping them focused on display only and improving testability."
            ),
            QuizQuestion(
                question: "What is the main drawback of the Singleton pattern?",
                options: [
                    "Difficult to test — you can't inject a mock singleton",
                    "Uses too much memory",
                    "Cannot be used in multi-threaded code",
                    "Only works in Objective-C"
                ],
                correctIndex: 0,
                explanation: "Singletons create tight coupling and make unit testing hard because you can't substitute them with mocks. Prefer DI with protocols for testable code."
            ),
            QuizQuestion(
                question: "Which GoF pattern does UITableViewDelegate implement?",
                options: ["Observer / Delegate", "Factory", "Singleton", "Decorator"],
                correctIndex: 0,
                explanation: "`UITableViewDelegate` is the iOS implementation of the Observer/Delegate pattern — the table view notifies its delegate of events (selection, height, etc.)."
            ),
        ]
    )

    // ──────────────────── 7. Networking ────────────────────
    static let networking = InterviewTopic(
        id: "networking",
        title: "Networking",
        subtitle: "URLSession, Codable, async/await",
        icon: "network",
        color: .cyan,
        difficulty: .intermediate,
        overview: "Networking is a core iOS skill. You should know URLSession (Apple's networking API), Codable for JSON parsing, and how to write robust async network layers using modern Swift concurrency.",
        keyConcepts: [
            KeyConcept(term: "URLSession", explanation: "Apple's HTTP networking API. Use .shared for simple requests or create a custom session with URLSessionConfiguration for control."),
            KeyConcept(term: "Codable", explanation: "Combines Encodable + Decodable. Use JSONDecoder/JSONEncoder to convert between JSON data and Swift structs."),
            KeyConcept(term: "CodingKeys", explanation: "Maps JSON key names to Swift property names. Useful when JSON uses snake_case but Swift uses camelCase."),
            KeyConcept(term: "Error Handling", explanation: "Networking can fail — model errors explicitly with an enum: .networkError, .decodingError, .notFound, etc."),
            KeyConcept(term: "URLComponents", explanation: "Build URLs safely without string concatenation. Handles percent-encoding automatically."),
        ],
        codeSnippets: [
            CodeSnippet(
                title: "Generic Network Layer with async/await",
                description: "Reusable, testable network service using modern Swift.",
                code: """
import Foundation

// Error types
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:         return "Invalid URL."
        case .invalidResponse:    return "Invalid server response."
        case .statusCode(let c):  return "HTTP error \\(c)."
        case .decodingError(let e): return "Decoding failed: \\(e)"
        }
    }
}

// Generic fetch — works for any Decodable type
func fetch<T: Decodable>(_ type: T.Type, from urlString: String) async throws -> T {
    guard let url = URL(string: urlString) else {
        throw NetworkError.invalidURL
    }

    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.invalidResponse
    }

    guard (200...299).contains(httpResponse.statusCode) else {
        throw NetworkError.statusCode(httpResponse.statusCode)
    }

    do {
        return try JSONDecoder().decode(T.self, from: data)
    } catch {
        throw NetworkError.decodingError(error)
    }
}

// Usage
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

Task {
    do {
        let user = try await fetch(User.self,
                                    from: "https://jsonplaceholder.typicode.com/users/1")
        print(user.name)
    } catch {
        print(error.localizedDescription)
    }
}
""",
                language: "swift"
            ),
        ],
        quiz: [
            QuizQuestion(
                question: "Which protocol do you conform to for automatic JSON encoding/decoding in Swift?",
                options: ["Codable", "Serializable", "JSONProtocol", "Parseable"],
                correctIndex: 0,
                explanation: "`Codable` (which is `Encodable & Decodable`) lets Swift automatically synthesise JSON encoding and decoding for structs and classes."
            ),
            QuizQuestion(
                question: "What does `URLSession.shared.data(from:)` return in an async context?",
                options: [
                    "(Data, URLResponse) tuple",
                    "Data only",
                    "URLResponse only",
                    "Result<Data, Error>"
                ],
                correctIndex: 0,
                explanation: "The async `data(from:)` method returns a `(Data, URLResponse)` tuple and throws on failure — replacing the completion-handler-based `dataTask`."
            ),
            QuizQuestion(
                question: "What is `CodingKeys` used for?",
                options: [
                    "Mapping JSON key names to different Swift property names",
                    "Securing API keys in the app",
                    "Defining which keys to exclude from serialisation",
                    "Setting default values for Codable properties"
                ],
                correctIndex: 0,
                explanation: "`CodingKeys` is a nested enum conforming to `CodingKey` that maps JSON keys (e.g. `user_name`) to Swift property names (e.g. `userName`)."
            ),
        ]
    )

    // ──────────────────── 8. Core Data ────────────────────
    static let coreData = InterviewTopic(
        id: "coredata",
        title: "Core Data",
        subtitle: "NSManagedObject, fetch requests, context",
        icon: "cylinder.split.1x2",
        color: .brown,
        difficulty: .advanced,
        overview: "Core Data is Apple's persistence framework. It manages an object graph and persists it to a SQLite database (or other stores). It's complex but powerful and widely used in large iOS apps.",
        keyConcepts: [
            KeyConcept(term: "NSPersistentContainer", explanation: "The modern entry point. Encapsulates the Core Data stack: NSManagedObjectModel + NSPersistentStoreCoordinator + NSManagedObjectContext."),
            KeyConcept(term: "NSManagedObjectContext", explanation: "The in-memory scratchpad. Changes exist here until you call save(). viewContext runs on the main thread."),
            KeyConcept(term: "NSManagedObject", explanation: "A single Core Data record. Usually subclassed with @NSManaged properties for each attribute."),
            KeyConcept(term: "NSFetchRequest", explanation: "A query against the persistent store. Set entity, predicate (filter), and sort descriptors."),
            KeyConcept(term: "@FetchRequest", explanation: "SwiftUI property wrapper that automatically fetches and updates when Core Data changes."),
            KeyConcept(term: "Background Context", explanation: "Use performBackgroundTask or a private queue context for heavy operations to avoid blocking the main thread."),
        ],
        codeSnippets: [
            CodeSnippet(
                title: "Core Data Stack Setup",
                description: "NSPersistentContainer setup and CRUD operations.",
                code: """
import CoreData

// 1. Setup (usually in App or AppDelegate)
lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "MyApp")
    container.loadPersistentStores { _, error in
        if let error { fatalError("Core Data failed: \\(error)") }
    }
    return container
}()

var context: NSManagedObjectContext { persistentContainer.viewContext }

// 2. Create a new record
func createTask(title: String) {
    let task = Task(context: context)   // NSManagedObject subclass
    task.id = UUID()
    task.title = title
    task.isCompleted = false
    task.createdAt = Date()
    save()
}

// 3. Fetch records
func fetchTasks() -> [Task] {
    let request: NSFetchRequest<Task> = Task.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
    return (try? context.fetch(request)) ?? []
}

// 4. Save context
func save() {
    guard context.hasChanges else { return }
    try? context.save()
}
""",
                language: "swift"
            ),
        ],
        quiz: [
            QuizQuestion(
                question: "What is `NSManagedObjectContext`?",
                options: [
                    "The in-memory scratchpad where Core Data changes live before being saved",
                    "The database file on disk",
                    "The schema definition of the Core Data model",
                    "The coordinator between contexts and stores"
                ],
                correctIndex: 0,
                explanation: "The `NSManagedObjectContext` (MOC) is an in-memory working space. All changes to managed objects exist only in the MOC until you call `save()`."
            ),
            QuizQuestion(
                question: "Which SwiftUI property wrapper automatically fetches and updates Core Data results?",
                options: ["@FetchRequest", "@State", "@CoreDataFetch", "@ObservedObject"],
                correctIndex: 0,
                explanation: "`@FetchRequest` in SwiftUI automatically fetches matching entities and re-renders the view when the Core Data store changes."
            ),
            QuizQuestion(
                question: "Why use a background context for heavy Core Data operations?",
                options: [
                    "To avoid blocking the main thread and causing UI jank",
                    "Background contexts are faster than the main context",
                    "Core Data requires background contexts for all operations",
                    "To bypass Core Data validation rules"
                ],
                correctIndex: 0,
                explanation: "The `viewContext` runs on the main thread. Heavy operations (importing large datasets, etc.) should use a private queue context so the UI stays responsive."
            ),
        ]
    )

    // ──────────────────── 9. Testing ────────────────────
    static let testing = InterviewTopic(
        id: "testing",
        title: "Testing",
        subtitle: "XCTest, unit tests, mocking protocols",
        icon: "checkmark.shield",
        color: .green,
        difficulty: .intermediate,
        overview: "Testing is a key indicator of code quality and engineering maturity. iOS uses XCTest for unit and UI tests. The best iOS code is designed for testability — using protocols and DI to make every class mockable.",
        keyConcepts: [
            KeyConcept(term: "XCTestCase", explanation: "Base class for test cases. Each test is a method starting with `test`. XCTAssert functions verify expectations."),
            KeyConcept(term: "Unit Test", explanation: "Tests a single unit (function/class) in isolation. Fast, no network/database. Dependencies are mocked."),
            KeyConcept(term: "Mock / Stub / Spy", explanation: "Test doubles. Mock: verifies interactions. Stub: returns preset values. Spy: records calls. All implement the same protocol as the real dependency."),
            KeyConcept(term: "Given/When/Then", explanation: "A clear unit test structure: Given (setup) → When (action) → Then (assert). Improves test readability."),
            KeyConcept(term: "UI Testing", explanation: "XCUITest drives the app like a real user. Slower but tests the full user journey. Use sparingly for critical flows."),
            KeyConcept(term: "Test Coverage", explanation: "Percentage of code exercised by tests. Aim for high coverage of business logic and ViewModels."),
        ],
        codeSnippets: [
            CodeSnippet(
                title: "Unit Testing a ViewModel with a Mock",
                description: "Testing MVVM ViewModel logic with a mock service.",
                code: """
import XCTest
@testable import iArchitect

// Mock service conforming to the same protocol
class MockTaskService: TaskServiceProtocol {
    var stubbedTasks: [MVVMTask] = []
    var addTaskCalled = false

    func fetchTasks() -> [MVVMTask] {
        return stubbedTasks
    }

    func addTask(title: String) -> MVVMTask {
        addTaskCalled = true
        let task = MVVMTask(title: title)
        stubbedTasks.append(task)
        return task
    }
}

// Test Case
class TaskViewModelTests: XCTestCase {
    var sut: MVVMTaskViewModel!     // System Under Test
    var mockService: MockTaskService!

    override func setUp() {
        super.setUp()
        mockService = MockTaskService()
        sut = MVVMTaskViewModel()   // or inject mock via DI
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // Given/When/Then structure
    func test_addTask_appendsToTaskList() {
        // Given
        XCTAssertEqual(sut.tasks.count, 0)

        // When
        sut.newTaskTitle = "Buy groceries"
        sut.addTask()

        // Then
        XCTAssertEqual(sut.tasks.count, 1)
        XCTAssertEqual(sut.tasks.first?.title, "Buy groceries")
    }

    func test_addTask_withEmptyTitle_doesNotAdd() {
        // Given
        sut.newTaskTitle = "   "   // whitespace only

        // When
        sut.addTask()

        // Then
        XCTAssertEqual(sut.tasks.count, 0)
    }
}
""",
                language: "swift"
            ),
        ],
        quiz: [
            QuizQuestion(
                question: "What is the purpose of a Mock object in unit testing?",
                options: [
                    "To replace a real dependency with a controllable test double",
                    "To speed up test execution",
                    "To replace the system under test",
                    "To run tests in parallel"
                ],
                correctIndex: 0,
                explanation: "A Mock replaces a real dependency (e.g., network service) with a controllable fake that returns preset values. This isolates the code under test from external systems."
            ),
            QuizQuestion(
                question: "What does XCTAssertEqual verify?",
                options: [
                    "That two values are equal",
                    "That a value is not nil",
                    "That a closure throws an error",
                    "That a test runs in a given time"
                ],
                correctIndex: 0,
                explanation: "`XCTAssertEqual(a, b)` fails the test if `a != b`. It's the most common assertion for verifying output values."
            ),
            QuizQuestion(
                question: "What does the `@testable import` attribute do?",
                options: [
                    "Exposes internal types and members to the test target",
                    "Makes all properties observable in tests",
                    "Disables code optimisation in tests",
                    "Automatically generates mock objects"
                ],
                correctIndex: 0,
                explanation: "`@testable import MyModule` allows the test target to access types and members marked `internal` (the default) in the target under test — without making them `public`."
            ),
        ]
    )

    // ──────────────────── 10. Swift Fundamentals ────────────────────
    static let swiftFundamentals = InterviewTopic(
        id: "swift",
        title: "Swift Fundamentals",
        subtitle: "Value vs reference, generics, closures",
        icon: "swift",
        color: .orange,
        difficulty: .intermediate,
        overview: "A solid understanding of Swift's type system, memory model, and language features is essential for any iOS interview. Value types (struct/enum) vs reference types (class) is one of the most commonly asked topics.",
        keyConcepts: [
            KeyConcept(term: "Value Type (struct/enum)", explanation: "Copied on assignment. Each variable has its own copy. Structs are the preferred type for model data in Swift. Stored on the stack (mostly)."),
            KeyConcept(term: "Reference Type (class)", explanation: "Shared on assignment. All variables point to the same instance on the heap. Use for objects that need identity or inheritance."),
            KeyConcept(term: "Protocol", explanation: "Defines a blueprint of methods and properties. Classes, structs, and enums can conform. Protocol-Oriented Programming (POP) is Swift's preferred paradigm."),
            KeyConcept(term: "Generics", explanation: "Write flexible, reusable functions and types that work with any type. `func swap<T>(_ a: inout T, _ b: inout T)` is a classic example."),
            KeyConcept(term: "@escaping closure", explanation: "A closure that outlives the function it was passed to. Required for async completions, stored closures. Captured values need careful memory management."),
            KeyConcept(term: "Optional", explanation: "Represents a value that may or may not exist. `nil` is only allowed for Optionals. Use `if let`, `guard let`, or `??` to safely unwrap."),
        ],
        codeSnippets: [
            CodeSnippet(
                title: "Value vs Reference Types",
                description: "How struct and class behave differently on assignment.",
                code: """
// Struct — VALUE type (copied on assignment)
struct Point {
    var x: Int
    var y: Int
}

var p1 = Point(x: 0, y: 0)
var p2 = p1           // COPY — p2 is independent
p2.x = 100
print(p1.x)           // 0 — p1 is unchanged

// ─────────────────────────────────────────

// Class — REFERENCE type (shared on assignment)
class Counter {
    var value: Int = 0
}

let c1 = Counter()
let c2 = c1           // REFERENCE — c2 points to same object!
c2.value = 100
print(c1.value)       // 100 — c1 is changed!
""",
                language: "swift"
            ),
            CodeSnippet(
                title: "Generics",
                description: "Type-safe generic stack implementation.",
                code: """
// Generic Stack — works with any type T
struct Stack<T> {
    private var elements: [T] = []

    mutating func push(_ element: T) {
        elements.append(element)
    }

    mutating func pop() -> T? {
        elements.popLast()
    }

    var top: T? { elements.last }
    var isEmpty: Bool { elements.isEmpty }
}

// Usage — type-inferred
var intStack = Stack<Int>()
intStack.push(1)
intStack.push(2)
print(intStack.pop()!)   // 2

var stringStack = Stack<String>()
stringStack.push("hello")
""",
                language: "swift"
            ),
        ],
        quiz: [
            QuizQuestion(
                question: "What happens when you assign a struct to a new variable?",
                options: [
                    "A copy is made — changes to one don't affect the other",
                    "Both variables point to the same instance",
                    "The original is invalidated",
                    "The struct is converted to a class"
                ],
                correctIndex: 0,
                explanation: "Structs are value types. Assignment creates an independent copy. Modifying one copy does not affect the other."
            ),
            QuizQuestion(
                question: "What does `@escaping` on a closure parameter mean?",
                options: [
                    "The closure may be called after the function returns",
                    "The closure runs on a background thread",
                    "The closure is called immediately",
                    "The closure cannot capture self"
                ],
                correctIndex: 0,
                explanation: "`@escaping` means the closure can outlive the function call — it's stored somewhere (e.g., a completion handler) and called later. Non-escaping closures are called within the function's scope."
            ),
            QuizQuestion(
                question: "What is Protocol-Oriented Programming (POP)?",
                options: [
                    "Preferring protocols and value types over class inheritance",
                    "Writing all code as protocol extensions",
                    "Using Objective-C protocols in Swift",
                    "A pattern where all classes are abstract"
                ],
                correctIndex: 0,
                explanation: "POP, as championed by Apple, favours composing behaviour via protocol conformance and extensions over deep class hierarchies. It plays well with Swift's value types (structs/enums)."
            ),
        ]
    )
}
