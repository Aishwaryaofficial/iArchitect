import SwiftUI

@main
struct iArchitectApp: App {
    @StateObject private var progressStore = ProgressStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(progressStore)
        }
    }
}
