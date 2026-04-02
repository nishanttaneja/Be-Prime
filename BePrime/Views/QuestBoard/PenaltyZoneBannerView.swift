import SwiftUI

struct PenaltyZoneBannerView: View {
    @State private var isPulsing = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.penaltyRed)

            Text("PENALTY ZONE")
                .font(.caption)
                .fontWeight(.heavy)
                .fontDesign(.monospaced)
                .foregroundStyle(.penaltyRed)

            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.penaltyRed)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(Color.penaltyDark)
                .overlay(
                    Capsule()
                        .stroke(Color.penaltyRed.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .penaltyGlow, radius: isPulsing ? 10 : 4)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
