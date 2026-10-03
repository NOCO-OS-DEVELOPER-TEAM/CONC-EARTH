import Combine
import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var screen: AppScreen = .home
    @Published var selectedRoute: FlightRoute?
    @Published var selectedSeat: Seat?
    @Published var selectedScenario: FlightScenario = .calm
    @Published var focusMinutes: Int = 45
    @Published var cameraMode: FlightCameraMode = .follow
    @Published var showStayFocusedHint = false

    let store: SessionStore
    let timer: FocusTimerService
    let audio: AudioService
    let location: LocationService
    let liveActivity: LiveActivityService

    private var cancellables = Set<AnyCancellable>()
    private var lastLiveActivityUpdate = Date.distantPast

    init(
        store: SessionStore = SessionStore(),
        timer: FocusTimerService = FocusTimerService(),
        audio: AudioService = AudioService(),
        location: LocationService = LocationService(),
        liveActivity: LiveActivityService = LiveActivityService()
    ) {
        self.store = store
        self.timer = timer
        self.audio = audio
        self.location = location
        self.liveActivity = liveActivity

        audio.configureSession()
        location.requestIfNeeded()
        restoreNavigationIfNeeded()

        timer.$now
            .sink { [weak self] date in
                self?.tick(at: date)
            }
            .store(in: &cancellables)
    }

    var homeAirport: Airport {
        location.suggestedAirport ?? store.homeAirport
    }

    var draftDistanceLabel: String {
        guard let route = selectedRoute else { return "—" }
        return String(format: "%.0f km", route.distanceKilometers)
    }

    func beginJourney() {
        if let suggested = location.suggestedAirport {
            store.setHomeAirport(suggested)
        }
        focusMinutes = selectedScenario.recommendedMinutes
        selectedRoute = RouteCatalog.routes(from: homeAirport.iata).first
            ?? RouteCatalog.connections.first
        screen = .flightSelection
    }

    func confirmFlight() {
        guard selectedRoute != nil else { return }
        screen = .seatSelection
    }

    func confirmSeat(_ seat: Seat) {
        selectedSeat = seat
        screen = .ticket
    }

    func openBoarding() {
        guard let route = selectedRoute, let seat = selectedSeat else { return }
        let session = FocusSession(
            route: route,
            seat: seat,
            scenario: selectedScenario,
            passengerName: store.passengerName,
            focusDurationSeconds: TimeInterval(focusMinutes * 60),
            status: .boarding
        )
        store.saveDraft(session)
        audio.playBoardingChime(enabled: store.soundsEnabled)
        screen = .boarding
    }

    func launchFlight() {
        store.updateActive { session in
            session.beginFlight()
        }
        guard let session = store.activeSession else { return }
        liveActivity.start(session: session)
        audio.playTakeoff(enabled: store.soundsEnabled)
        audio.setCabinNoise(enabled: true, soundsOn: store.soundsEnabled)
        cameraMode = .follow
        timer.start()
        screen = .inFlight
    }

    func pauseFlight() {
        store.updateActive { $0.pause() }
        if let session = store.activeSession {
            liveActivity.update(session: session)
        }
        audio.setCabinNoise(enabled: false, soundsOn: store.soundsEnabled)
    }

    func resumeFlight() {
        store.updateActive { $0.resume() }
        if let session = store.activeSession {
            liveActivity.update(session: session)
        }
        audio.setCabinNoise(enabled: true, soundsOn: store.soundsEnabled)
        timer.start()
    }

    func togglePause() {
        guard let status = store.activeSession?.status else { return }
        if status == .paused {
            resumeFlight()
        } else if status == .inFlight {
            pauseFlight()
        }
    }

    func finishFlight() {
        guard let snapshot = store.activeSession,
              snapshot.status == .inFlight || snapshot.status == .paused else { return }
        store.updateActive { $0.complete() }
        liveActivity.end(session: snapshot)
        audio.playLanding(enabled: store.soundsEnabled)
        audio.stopAll()
        timer.stop()
        screen = .arrival
    }

    func dismissArrival() {
        selectedSeat = nil
        selectedRoute = nil
        screen = .home
    }

    func openFlightLog() {
        screen = .flightLog
    }

    func goHome() {
        screen = .home
    }

    func backFromSelection() {
        screen = .home
    }

    func backFromSeat() {
        screen = .flightSelection
    }

    func backFromTicket() {
        screen = .seatSelection
    }

    func pulseStayFocused() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            showStayFocusedHint = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.showStayFocusedHint = false
            }
        }
    }

    private func restoreNavigationIfNeeded() {
        guard let session = store.activeSession else { return }
        selectedRoute = session.route
        selectedSeat = session.seat
        selectedScenario = session.scenario
        focusMinutes = session.focusMinutes
        switch session.status {
        case .inFlight, .paused:
            timer.start()
            liveActivity.start(session: session)
            audio.setCabinNoise(enabled: session.status == .inFlight, soundsOn: store.soundsEnabled)
            screen = .inFlight
        case .boarding:
            screen = .boarding
        case .completed:
            screen = .arrival
        default:
            break
        }
    }

    private func tick(at date: Date) {
        guard let session = store.activeSession else { return }
        guard session.status == .inFlight || session.status == .paused else { return }

        if session.progress(at: date) >= 1, session.status == .inFlight {
            finishFlight()
            return
        }

        if session.status == .inFlight, date.timeIntervalSince(lastLiveActivityUpdate) >= 5 {
            lastLiveActivityUpdate = date
            liveActivity.update(session: session)
        }
    }
}
