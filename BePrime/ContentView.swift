import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dungeon", systemImage: "flame.fill", value: 0) {
                QuestBoardView()
            }
            Tab("Progress", systemImage: "chart.bar.fill", value: 1) {
                ProgressDashboardView()
            }
            Tab("Hunter", systemImage: "person.fill", value: 2) {
                HunterCardView()
            }
            Tab("Settings", systemImage: "gearshape.fill", value: 3) {
                SettingsView()
            }
        }
        .tint(.systemBlue)
        .preferredColorScheme(.dark)
    }
}
