import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                ArchitectureHubView()
            }
            .tabItem {
                Label("Architectures", systemImage: "rectangle.3.group.fill")
            }

            NavigationStack {
                InterviewPrepView()
            }
            .tabItem {
                Label("Interview Prep", systemImage: "brain.head.profile")
            }

            NavigationStack {
                ComparisonView()
            }
            .tabItem {
                Label("Compare", systemImage: "arrow.left.arrow.right.square.fill")
            }

            NavigationStack {
                LearningProgressView()
            }
            .tabItem {
                Label("Progress", systemImage: "chart.bar.fill")
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(ProgressStore())
}
