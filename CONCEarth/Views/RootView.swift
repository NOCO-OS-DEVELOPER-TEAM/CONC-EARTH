import SwiftUI

struct RootView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()

            switch coordinator.screen {
            case .home:
                HomeView()
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            case .flightSelection:
                FlightSelectionView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .seatSelection:
                SeatSelectionView()
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            case .ticket:
                TicketView()
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            case .boarding:
                BoardingView()
                    .transition(.opacity)
            case .inFlight:
                InFlightView()
                    .transition(.opacity)
            case .arrival:
                ArrivalView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
            case .flightLog:
                FlightLogView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: coordinator.screen)
    }
}
