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
                if let flight = lastFlight {
                    Text("Welcome to \(flight.route.destination.city)")
                        .font(CEFont.body(17))
                        .foregroundStyle(.white.opacity(0.6))
                    Text("\(flight.route.originIATA) → \(flight.route.destinationIATA) · \(TimeFormatting.shortDuration(flight.focusDurationSeconds))")
                        .font(CEFont.body(13, weight: .medium))
                        .foregroundStyle(CEColor.horizonTeal)
                        .padding(.top, 4)
                }
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
}

struct ConfettiView: View {
    private struct Piece: Identifiable {
        let id: Int
        let x: CGFloat
        let hue: Double
        let size: CGFloat
        let rot: Double
        let yFactor: CGFloat
    }

    private let pieces: [Piece] = (0..<20).map { i in
        Piece(
            id: i,
            x: CGFloat((i * 37) % 100) / 100.0,
            hue: Double((i * 47) % 100) / 100.0,
            size: CGFloat((i % 5) + 5),
            rot: Double((i * 23) % 360),
            yFactor: 0.12 + CGFloat(i % 7) * 0.05
        )
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    confettiPiece(piece, in: geo.size)
                }
            }
        }
    }

    private func confettiPiece(_ piece: Piece, in size: CGSize) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color(hue: piece.hue, saturation: 0.75, brightness: 0.95))
            .frame(width: piece.size, height: piece.size * 1.4)
            .rotationEffect(.degrees(piece.rot))
            .position(x: piece.x * size.width, y: size.height * piece.yFactor)
            .opacity(0.85)
    }
}
