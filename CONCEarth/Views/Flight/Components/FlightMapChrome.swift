import SwiftUI

struct FlightGlassStack: View {
    let left: [FlightChromeButton]
    let right: [FlightChromeButton]

    var body: some View {
        HStack(alignment: .top) {
            VStack(spacing: 10) {
                ForEach(left) { button in
                    chromeButton(button)
                }
            }
            Spacer()
            VStack(spacing: 10) {
                ForEach(right) { button in
                    chromeButton(button)
                }
            }
        }
    }

    private func chromeButton(_ button: FlightChromeButton) -> some View {
        Button(action: button.action) {
            Image(systemName: button.systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(button.emphasized ? CEColor.ink : .white)
                .frame(width: button.wide ? 52 : 44, height: 44)
                .background {
                    if button.emphasized {
                        Capsule().fill(.white)
                    } else {
                        Capsule().fill(.ultraThinMaterial)
                    }
                }
                .overlay {
                    Capsule().stroke(.white.opacity(0.18), lineWidth: 0.8)
                }
        }
        .buttonStyle(.plain)
    }
}

struct FlightChromeButton: Identifiable {
    let id = UUID()
    let systemName: String
    var emphasized: Bool = false
    var wide: Bool = false
    let action: () -> Void
}

struct FlightBottomMetrics: View {
    let leftLabel: String
    let leftValue: String
    let rightLabel: String
    let rightValue: String

    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(leftLabel)
                    .font(CEFont.body(13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.72))
                Text(leftValue)
                    .font(CEFont.display(34, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(rightLabel)
                    .font(CEFont.body(13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.72))
                Text(rightValue)
                    .font(CEFont.display(34, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 22)
        .background(
            LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }
}
