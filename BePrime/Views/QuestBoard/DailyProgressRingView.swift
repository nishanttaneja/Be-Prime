import SwiftUI

struct DailyProgressRingView: View {
    let completed: Int
    let total: Int
    var size: CGFloat = 80

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    private var isCleared: Bool { completed == total && total > 0 }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 6)

            // Progress ring
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    isCleared ? Color.xpGreen : Color.systemBlue,
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)

            // Center text
            if isCleared {
                VStack(spacing: 0) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title3)
                        .foregroundColor(.xpGreen)
                    Text("CLEAR")
                        .font(.caption2)
                        .fontDesign(.monospaced)
                        .foregroundColor(.xpGreen)
                }
            } else {
                VStack(spacing: 0) {
                    Text("\(completed)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("/\(total)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: size, height: size)
    }
}
