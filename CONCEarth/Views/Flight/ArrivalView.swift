import SwiftUI

struct ArrivalView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var store: SessionStore

    @State private var showConfetti = false

    private var lastFlight: FocusSession? {
        store.completedSessions.first
    }

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()
            LinearGradient(
                colors: [Color.white.opacity(0.08), .clear, CEColor.earthDeep],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 14) {
                Spacer()
                Text("Landing Complete")
                    .font(CEFont.display(34, weight: .bold))
                    .foregroundStyle(.white)
                destinationText
                Spacer()
                PrimaryPillButton(title: "Done") {
                    coordinator.dismissArrival()
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 28)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                showConfetti = true
            }
        }
    }

    @ViewBuilder
    private var destinationText: some View {
        if let flight = lastFlight {
            Text("Welcome to \(flight.route.destination.city)")
                .font(CEFont.body(17))
                .foregroundStyle(.white.opacity(0.6))
            Text("\(flight.route.originIATA) → \(flight.route.destinationIATA) · \(TimeFormatting.shortDuration(flight.focusDurationSeconds))")
                .font(CEFont.body(13, weight: .medium))
                .foregroundStyle(CEColor.horizonTeal)
                .padding(.top, 4)
        }
    }
}

struct ConfettiView: View {
    var body: some View {
        Canvas { context, size in
            for i in 0..<24 {
                let x = CGFloat((i * 37) % 100) / 100.0 * size.width
                let y = size.height * (0.10 + CGFloat(i % 8) * 0.04)
                let w = CGFloat((i % 5) + 5)
                let rect = CGRect(x: x, y: y, width: w, height: w * 1.4)
                let hue = Double((i * 47) % 100) / 100.0
                context.fill(
                    Path(roundedRect: rect, cornerRadius: 2),
                    with: .color(Color(hue: hue, saturation: 0.75, brightness: 0.95).opacity(0.85))
                )
            }
        }
    }
}
