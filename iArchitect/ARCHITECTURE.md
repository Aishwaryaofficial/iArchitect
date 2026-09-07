// iArchitect
// ──────────────────────────────────────────────────────────────────
// Code Architecture Reference
//
// This file documents the key architectural decisions and patterns
// used in the iArchitect app itself (not the demo modules).
//
// App Architecture: MVVM + EnvironmentObject dependency injection
//
// Data Flow:
//   ProgressStore (ObservableObject)
//     └─ injected via .environmentObject() at the root
//     └─ consumed in: ArchitectureDetailView, InterviewPrepView,
//                     TopicDetailView, ProgressView
//
// Navigation: SwiftUI NavigationStack (push-based) inside each tab.
//
// State Management:
//   • @State       — local, ephemeral view state (text fields, tab selection)
//   • @StateObject — owns the ViewModel/Store lifetime
//   • @ObservedObject — receives a ViewModel/Store from parent
//   • @EnvironmentObject — ProgressStore shared across the whole app
//
// No External Dependencies:
//   • Syntax highlighting: custom SyntaxHighlighter (NSAttributedString + NSRegularExpression)
//   • Persistence: UserDefaults via ProgressStore
//   • Combine: built-in (used in MVVM and MVP demo modules)
//
// File Ownership:
//   App/            — entry point and tab shell only
//   Modules/        — self-contained architecture demos, no cross-module imports
//   ArchitectureHub/— hub UI + code viewer + diagrams
//   InterviewPrep/ — topic content, quiz engine, views
//   Comparison/    — pattern diff view
//   Progress/      — store + dashboard view
// ──────────────────────────────────────────────────────────────────
