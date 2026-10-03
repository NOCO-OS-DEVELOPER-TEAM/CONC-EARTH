import SwiftUI

struct FlightLogView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var store: SessionStore

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    GlassCircleButton(systemName: "chevron.left") {
                        coordinator.goHome()
                    }
                    Spacer()
                    Text("FlightLog")
                        .font(CEFont.body(17, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Travel journal")
                            .font(CEFont.body(13))
                            .foregroundStyle(.white.opacity(0.4))

                        if store.completedSessions.isEmpty {
                            emptyState
                        } else {
                            ForEach(store.completedSessions) { session in
                                Button {
                                    coordinator.openBoardingPass(session.id)
                                } label: {
                                    flightRow(session)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
    }

    private func flightRow(_ session: FocusSession) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("\(session.route.originIATA) → \(session.route.destinationIATA)")
                    .font(CEFont.body(17, weight: .semibold))
                    .foregroundStyle(.white)
                Text(session.route.destination.displayTitle)
                    .font(CEFont.body(13))
                    .foregroundStyle(.white.opacity(0.55))
                HStack(spacing: 10) {
                    Text(TimeFormatting.shortDuration(session.focusDurationSeconds))
                    Text("·")
                    Text(session.seat.unlocksWindowView ? "Window" : session.seat.displayCode)
                    Text("·")
                    Text(String(format: "%.0f km", session.route.distanceKilometers))
                }
                .font(CEFont.body(12))
                .foregroundStyle(.white.opacity(0.4))

                if session.hasPurpose {
                    Text(session.focusPurpose)
                        .font(CEFont.body(12))
                        .foregroundStyle(CEColor.horizonTeal.opacity(0.9))
                        .padding(.top, 2)
                }
            }
            Spacer()
            Text("Pass")
                .font(CEFont.body(11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.45))
        }
        .padding(16)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("No journeys yet")
                .font(CEFont.body(16, weight: .semibold))
                .foregroundStyle(.white)
            Text("Completed focus flights become part of your journal.")
                .font(CEFont.body(13))
                .foregroundStyle(.white.opacity(0.45))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}
