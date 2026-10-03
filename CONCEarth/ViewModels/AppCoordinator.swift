import Combine
import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var screen: AppScreen = .home
    @Published var selectedRoute: FlightRoute?
    @Published var selectedSeat: Seat?
    @Published var selectedScenario: FlightScenario = .calm
    @Published var focusMinutes: Int = 45
    @Published var focusPurpose: String = ""
    @Published var cameraMode: FlightCameraMode = .follow
    @Published var presentationMode: FlightPresentation = .map
    @Published var showStayFocusedHint = false
    @Published var surpriseReveal: FlightRoute?

    let store: SessionStore
    let journey: JourneyStore
    let timer: FocusTimerService
    let audio: AudioService
    let location: LocationService
    let liveActivity: LiveActivityService

    private var cancellables = Set<AnyCancellable>()
    private var lastLiveActivityUpdate = Date.distantPast
    private var lastCompletedSession: FocusSession?

    enum FlightPresentation: String {
        case map
        case window
    }

    init() {
        let store = SessionStore()
        let journey = JourneyStore()
        let timer = FocusTimerService()
        let audio = AudioService()
        let location = LocationService()
        let liveActivity = LiveActivityService()

        self.store = store
        self.journey = journey
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
        let suggested = location.suggestedAirport ?? store.homeAirport
        if journey.isUnlocked(suggested.iata) { return suggested }
        return store.homeAirport
    }

    var unlockedIATAs: Set<String> { journey.unlockedAirportIATAs }

    var draftDistanceLabel: String {
        guard let route = selectedRoute else { return "—" }
        return String(format: "%.0f km", route.distanceKilometers)
    }

    var completedSessionForArrival: FocusSession? {
        lastCompletedSession ?? store.completedSessions.first
    }

    // MARK: - Navigation

    func beginJourney() {
        if let suggested = location.suggestedAirport, journey.isUnlocked(suggested.iata) {
            store.setHomeAirport(suggested)
        }
        focusMinutes = selectedScenario.recommendedMinutes
        selectedRoute = RouteCatalog.routes(from: homeAirport.iata, unlocked: unlockedIATAs).first
            ?? RouteCatalog.connections.first { unlockedIATAs.contains($0.originIATA) && unlockedIATAs.contains($0.destinationIATA) }
        screen = .flightSelection
    }

    func openTakeMeSomewhere() {
        focusMinutes = 45
        surpriseReveal = nil
        screen = .takeMeSomewhere
    }

    func revealSurpriseDestination() {
        guard let route = RouteCatalog.surpriseRoute(
            minutes: focusMinutes,
            from: homeAirport.iata,
            unlocked: unlockedIATAs
        ) else { return }
        withAnimation(.easeInOut(duration: 0.45)) {
            surpriseReveal = route
            selectedRoute = route
        }
    }

    func startSurpriseFlight() {
        guard selectedRoute != nil else { return }
        screen = .focusPurpose
    }

    func confirmFlight() {
        guard selectedRoute != nil else { return }
        screen = .focusPurpose
    }

    func confirmFocusPurpose() {
        screen = .seatSelection
    }

    func skipFocusPurpose() {
        focusPurpose = ""
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
            focusPurpose: focusPurpose.trimmingCharacters(in: .whitespacesAndNewlines),
            focusDurationSeconds: TimeInterval(focusMinutes * 60),
            status: .boarding
        )
        store.saveDraft(session)
        audio.playBoardingChime(enabled: store.soundsEnabled)
        screen = .boarding
    }

    func launchFlight() {
        store.updateActive { session in
            session.beginTakeoff()
        }
        guard let session = store.activeSession else { return }
        liveActivity.start(session: session)
        audio.playTakeoff(enabled: store.soundsEnabled)
        presentationMode = session.seat.unlocksWindowView ? .window : .map
        cameraMode = session.seat.unlocksWindowView ? .window : .follow
        timer.start()
        screen = .takeoff

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { [weak self] in
            self?.enterCruise()
        }
    }

    func enterCruise() {
        guard store.activeSession?.status == .takeoff else { return }
        store.updateActive { $0.enterCruise() }
        audio.setCabinNoise(enabled: true, soundsOn: store.soundsEnabled)
        screen = .inFlight
        if let session = store.activeSession {
            liveActivity.update(session: session)
        }
    }

    func togglePresentation() {
        guard store.activeSession?.seat.unlocksWindowView == true else {
            presentationMode = .map
            cameraMode = .follow
            return
        }
        withAnimation(.easeInOut(duration: 0.45)) {
            if presentationMode == .window {
                presentationMode = .map
                cameraMode = .follow
            } else {
                presentationMode = .window
                cameraMode = .window
            }
        }
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
        } else if status == .inFlight || status == .landing || status == .takeoff {
            pauseFlight()
        }
    }

    func finishFlight() {
        guard screen != .landing, screen != .arrival else { return }
        guard var snapshot = store.activeSession else { return }
        guard snapshot.status == .inFlight || snapshot.status == .paused || snapshot.status == .landing || snapshot.status == .takeoff else { return }

        let sessionID = snapshot.id
        store.updateActive { $0.enterLanding() }
        screen = .landing
        audio.playLanding(enabled: store.soundsEnabled)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { [weak self] in
            guard let self else { return }
            self.store.updateActive { $0.complete() }
            if let completed = self.store.completedSessions.first(where: { $0.id == sessionID }) {
                snapshot = completed
            } else {
                snapshot.complete()
            }
            self.lastCompletedSession = snapshot
            self.journey.processCompletion(session: snapshot, store: self.store)
            self.liveActivity.end(session: snapshot)
            self.audio.stopAll()
            self.timer.stop()
            self.screen = .arrival
        }
    }

    func dismissArrival() {
        selectedSeat = nil
        selectedRoute = nil
        focusPurpose = ""
        surpriseReveal = nil
        presentationMode = .map
        journey.consumePendingUnlock()
        journey.consumePendingAchievement()
        screen = .home
    }

    func openFlightLog() { screen = .flightLog }
    func openWorld() { screen = .world }
    func openJourney() { screen = .journey }
    func goHome() { screen = .home }
    func openBoardingPass(_ id: UUID) { screen = .boardingPass(id) }

    func backFromSelection() { screen = .home }
    func backFromTakeMeSomewhere() { screen = .home }
    func backFromPurpose() { screen = selectedRoute != nil && surpriseReveal != nil ? .takeMeSomewhere : .flightSelection }
    func backFromSeat() { screen = .focusPurpose }
    func backFromTicket() { screen = .seatSelection }

    func pulseStayFocused() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            showStayFocusedHint = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
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
        focusPurpose = session.focusPurpose
        switch session.status {
        case .inFlight, .paused, .landing:
            timer.start()
            liveActivity.start(session: session)
            audio.setCabinNoise(enabled: session.status != .paused, soundsOn: store.soundsEnabled)
            presentationMode = session.seat.unlocksWindowView ? .window : .map
            cameraMode = presentationMode == .window ? .window : .follow
            screen = .inFlight
        case .takeoff:
            timer.start()
            liveActivity.start(session: session)
            screen = .takeoff
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                self?.enterCruise()
            }
        case .boarding:
            screen = .boarding
        case .completed:
            lastCompletedSession = session
            screen = .arrival
        default:
            break
        }
    }

    private func tick(at date: Date) {
        guard let session = store.activeSession else { return }
        guard session.status == .inFlight || session.status == .paused || session.status == .landing || session.status == .takeoff else { return }

        if session.progress(at: date) >= 1, session.status != .paused, screen != .landing, screen != .arrival {
            finishFlight()
            return
        }

        if (session.status == .inFlight || session.status == .landing),
           FlightPhase.cruiseOrLanding(progress: session.progress(at: date), remaining: session.remainingSeconds(at: date)) == .landing,
           session.status == .inFlight {
            store.updateActive { $0.enterLanding() }
        }

        if session.status != .paused, date.timeIntervalSince(lastLiveActivityUpdate) >= 5 {
            lastLiveActivityUpdate = date
            liveActivity.update(session: session)
        }
    }
}
