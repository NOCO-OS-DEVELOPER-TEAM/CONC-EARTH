import SwiftUI

struct RootView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()

            switch coordinator.screen {
            case .home:
                HomeView()
            case .takeMeSomewhere:
                TakeMeSomewhereView()
            case .flightSelection:
                FlightSelectionView()
            case .focusPurpose:
                FocusPurposeView()
            case .seatSelection:
                SeatSelectionView()
            case .ticket:
                TicketView()
            case .boarding:
                BoardingView()
            case .takeoff:
                TakeoffView()
            case .inFlight:
                InFlightView()
            case .landing:
                LandingPhaseView()
            case .arrival:
                ArrivalView()
            case .flightLog:
                FlightLogView()
            case .world:
                WorldMapView()
            case .journey:
                JourneyView()
            case .boardingPass(let id):
                BoardingPassDetailView(sessionID: id)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: coordinator.screen)
    }
}
