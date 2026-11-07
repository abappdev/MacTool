import SwiftUI

/// Menu-bar label: SF Symbol with a countdown ring matching the Cursor Movement interval.
struct TrayProgressIcon: View {
    @ObservedObject var cursorMovement: CursorMovementService

    private let iconSize: CGFloat = 18
    private let ringLineWidth: CGFloat = 1.75

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 20.0)) { context in
            let progress = cursorMovement.progress(at: context.date)

            ZStack {
                Image(systemName: "cursorarrow.click.2")
                    .font(.system(size: 11, weight: .semibold))
                    .offset(x: 0.5, y: 0)

                if let progress {
                    // Track
                    Circle()
                        .stroke(Color.primary.opacity(0.22), lineWidth: ringLineWidth)

                    // Progress (fills over the selected interval, e.g. 30s → full ring)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.primary,
                            style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                }
            }
            .frame(width: iconSize, height: iconSize)
            .accessibilityLabel(accessibilityLabel(progress: progress))
        }
    }

    private func accessibilityLabel(progress: Double?) -> String {
        guard let progress, let duration = cursorMovement.cycleDuration else {
            return "MacTool, Cursor Movement off"
        }
        let secondsLeft = max(0, Int(ceil(duration * (1 - progress))))
        return "MacTool, next cursor move in \(secondsLeft) seconds"
    }
}
