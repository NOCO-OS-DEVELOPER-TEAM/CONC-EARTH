import ActivityKit
import SwiftUI
import WidgetKit

struct FocusFlightLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusFlightAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("CONC EARTH")
                            .font(.caption2.weight(.bold))
                        Text("\(context.state.originIATA) → \(context.state.destinationIATA)")
                            .font(.caption.weight(.semibold))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(remainingLabel(context.state.remainingSeconds))
                        .font(.caption.monospacedDigit().weight(.bold))
                }
                DynamicIslandExpandedRegion(.center) {
                    ProgressView(value: context.state.progress)
                        .tint(.teal)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.statusText)
                        Spacer()
                        Text("Seat \(context.state.seatCode)")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: "airplane")
            } compactTrailing: {
                Text(remainingLabel(context.state.remainingSeconds))
                    .font(.caption2.monospacedDigit().weight(.semibold))
            } minimal: {
                Image(systemName: "airplane")
            }
        }
    }

    private func remainingLabel(_ seconds: Int) -> String {
        let m = max(0, seconds) / 60
        return "\(m)m"
    }
}

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<FocusFlightAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("CONC EARTH")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.teal)
                Spacer()
                Text(context.state.statusText)
                    .font(.caption.weight(.semibold))
            }

            HStack {
                Text("\(context.state.originIATA) → \(context.state.destinationIATA)")
                    .font(.title3.weight(.bold))
                Spacer()
                Text(clock(context.state.remainingSeconds))
                    .font(.title3.monospacedDigit().weight(.bold))
            }

            ProgressView(value: context.state.progress)
                .tint(.teal)

            HStack {
                Text(context.attributes.flightNumber)
                Spacer()
                Text("Seat \(context.state.seatCode)")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .activityBackgroundTint(Color.black.opacity(0.85))
        .activitySystemActionForegroundColor(.white)
    }

    private func clock(_ seconds: Int) -> String {
        let total = max(0, seconds)
        let m = total / 60
        let s = total % 60
        return String(format: "%02d:%02d", m, s)
    }
}
