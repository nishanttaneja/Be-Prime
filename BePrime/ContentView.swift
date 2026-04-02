import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var refreshID = UUID()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dungeon", systemImage: "flame.fill", value: 0) {
                QuestBoardView()
                    .id("quest-\(refreshID)")
            }
            Tab("Progress", systemImage: "chart.bar.fill", value: 1) {
                ProgressDashboardView()
                    .id("progress-\(refreshID)")
            }
            Tab("Hunter", systemImage: "person.fill", value: 2) {
                HunterCardView()
                    .id("hunter-\(refreshID)")
            }
            Tab("Settings", systemImage: "gearshape.fill", value: 3) {
                SettingsView()
            }
        }
        .tint(.systemBlue)
        .preferredColorScheme(.dark)
        .onChange(of: selectedTab) {
            // Force refresh when switching tabs to pick up latest data
            refreshID = UUID()
        }
    }
}
