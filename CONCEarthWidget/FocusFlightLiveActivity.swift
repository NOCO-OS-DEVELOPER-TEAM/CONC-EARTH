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
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text("\(context.state.originIATA) → \(context.state.destinationIATA)")
                            .font(.caption.weight(.semibold))
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isLanded {
                        Text("LANDED")
                            .font(.caption.weight(.bold))
                    } else {
                        Text(clock(context.state.remainingSeconds))
                            .font(.caption.monospacedDigit().weight(.bold))
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isLanded {
                        Text("Focus \(context.state.focusMinutes)m · \(context.state.distanceKilometers) km")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        ProgressView(value: context.state.progress)
                            .tint(.teal)
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.isLanded ? "airplane.arrival" : "airplane")
            } compactTrailing: {
                if context.state.isLanded {
                    Text("OK")
                        .font(.caption2.weight(.bold))
                } else {
                    Text(short(context.state.remainingSeconds))
                        .font(.caption2.monospacedDigit().weight(.semibold))
                }
            } minimal: {
                Image(systemName: "airplane")
            }
        }
    }

    private func short(_ seconds: Int) -> String {
        "\(max(0, seconds) / 60)m"
    }

    private func clock(_ seconds: Int) -> String {
        let total = max(0, seconds)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}

private struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<FocusFlightAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("CONC EARTH")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.teal)
                Spacer()
                Text(context.state.statusText)
                    .font(.caption.weight(.semibold))
            }

            HStack {
                Text("\(context.state.originIATA) → \(context.state.destinationIATA)")
                    .font(.title3.weight(.bold))
                Spacer()
                if context.state.isLanded {
                    Text("\(context.state.focusMinutes) min")
                        .font(.title3.weight(.bold))
                } else {
                    Text(clock(context.state.remainingSeconds))
                        .font(.title3.monospacedDigit().weight(.bold))
                }
            }

            if context.state.isLanded {
                Text("Distance \(context.state.distanceKilometers) km")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ProgressView(value: context.state.progress)
                    .tint(.teal)
            }
        }
        .padding(16)
        .activityBackgroundTint(Color.black.opacity(0.85))
        .activitySystemActionForegroundColor(.white)
    }

    private func clock(_ seconds: Int) -> String {
        let total = max(0, seconds)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
