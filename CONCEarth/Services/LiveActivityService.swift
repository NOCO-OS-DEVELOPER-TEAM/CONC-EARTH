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
        let state = FocusFlightAttributes.ContentState(
            originIATA: session.route.originIATA,
            destinationIATA: session.route.destinationIATA,
            remainingSeconds: Int(session.remainingSeconds()),
            progress: session.progress(),
            statusText: "In Flight",
            seatCode: session.seat.displayCode
        )

        do {
            activity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            // Live Activities may be disabled by the user; flight continues normally.
        }
    }

    func update(session: FocusSession) {
        guard let activity else { return }
        let state = FocusFlightAttributes.ContentState(
            originIATA: session.route.originIATA,
            destinationIATA: session.route.destinationIATA,
            remainingSeconds: Int(session.remainingSeconds()),
            progress: session.progress(),
            statusText: session.status == .paused ? "Paused" : "In Flight",
            seatCode: session.seat.displayCode
        )
        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }
    }

    func end(session: FocusSession?) {
        guard let activity else { return }
        let state = FocusFlightAttributes.ContentState(
            originIATA: session?.route.originIATA ?? "—",
            destinationIATA: session?.route.destinationIATA ?? "—",
            remainingSeconds: 0,
            progress: 1,
            statusText: "Landed",
            seatCode: session?.seat.displayCode ?? "—"
        )
        Task {
            await activity.end(.init(state: state, staleDate: nil), dismissalPolicy: .after(.now + 60))
        }
        self.activity = nil
    }
}
