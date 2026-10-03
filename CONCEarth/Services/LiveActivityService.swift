import ActivityKit
import Combine
import Foundation

@MainActor
final class LiveActivityService: ObservableObject {
    private var activity: Activity<FocusFlightAttributes>?

    func start(session: FocusSession) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = FocusFlightAttributes(
            flightNumber: session.route.flightNumber,
            scenarioTitle: session.scenario.title
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state(for: session), staleDate: nil),
                pushType: nil
            )
        } catch {
            // Live Activities may be disabled; flight continues normally.
        }
    }

    func update(session: FocusSession) {
        guard let activity else { return }
        Task {
            await activity.update(.init(state: state(for: session), staleDate: nil))
        }
    }

    func end(session: FocusSession?) {
        guard let activity else { return }
        let finalState: FocusFlightAttributes.ContentState
        if let session {
            finalState = FocusFlightAttributes.ContentState(
                originIATA: session.route.originIATA,
                destinationIATA: session.route.destinationIATA,
                remainingSeconds: 0,
                progress: 1,
                statusText: "LANDED",
                seatCode: session.seat.displayCode,
                focusMinutes: session.focusMinutes,
                distanceKilometers: Int(session.route.distanceKilometers.rounded()),
                isLanded: true
            )
        } else {
            finalState = FocusFlightAttributes.ContentState(
                originIATA: "—",
                destinationIATA: "—",
                remainingSeconds: 0,
                progress: 1,
                statusText: "LANDED",
                seatCode: "—",
                focusMinutes: 0,
                distanceKilometers: 0,
                isLanded: true
            )
        }
        Task {
            await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .after(.now + 90))
        }
        self.activity = nil
    }

    private func state(for session: FocusSession) -> FocusFlightAttributes.ContentState {
        let phase = session.phase()
        let status: String
        switch session.status {
        case .paused: status = "Paused"
        case .takeoff: status = "Takeoff"
        case .landing: status = "Landing"
        default: status = phase == .landing ? "Landing" : "In Flight"
        }

        return FocusFlightAttributes.ContentState(
            originIATA: session.route.originIATA,
            destinationIATA: session.route.destinationIATA,
            remainingSeconds: Int(session.remainingSeconds()),
            progress: session.progress(),
            statusText: status,
            seatCode: session.seat.displayCode,
            focusMinutes: session.focusMinutes,
            distanceKilometers: Int(session.route.distanceKilometers.rounded()),
            isLanded: false
        )
    }
}
