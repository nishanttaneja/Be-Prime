import SwiftUI

struct PowerLevelView: View {
    let powerLevel: Int

    @State private var displayedValue: Int = 0

    var body: some View {
        VStack(spacing: 2) {
            Text("POWER LEVEL")
                .font(.caption2)
                .fontWeight(.semibold)
                .fontDesign(.monospaced)
                .foregroundStyle(.gray)

            Text("\(displayedValue)")
                .font(.system(size: 32, weight: .heavy, design: .monospaced))
                .foregroundStyle(.systemBlue)
                .shadow(color: .systemGlow, radius: 8)
                .contentTransition(.numericText(value: Double(displayedValue)))
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                displayedValue = powerLevel
            }
        }
        .onChange(of: powerLevel) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                displayedValue = newValue
            }
        }
    }
}
