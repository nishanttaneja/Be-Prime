import SwiftUI

struct XPProgressBar: View {
    let earned: Int
    let required: Int
    var showLabel: Bool = true
    var height: CGFloat = 8

    private var progress: Double {
        guard required > 0 else { return 0 }
        return min(1.0, Double(earned) / Double(required))
    }

    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: height)

                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(
                            LinearGradient(
                                colors: [.systemBlue, .xpGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: height)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: height)

            if showLabel {
                HStack {
                    Text("\(earned) / \(required) XP")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .foregroundStyle(.systemBlue)
                }
            }
        }
    }
}
