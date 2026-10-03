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
                        .font(CEFont.body(17, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Passenger name")
                                .font(CEFont.body(12))
                                .foregroundStyle(.white.opacity(0.5))
                            TextField("Traveler", text: $store.passengerName)
                                .textInputAutocapitalization(.words)
                                .padding(12)
                                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                                .foregroundStyle(.white)

                            Toggle("Flight sounds", isOn: $store.soundsEnabled)
                                .tint(CEColor.horizonTeal)
                                .foregroundStyle(.white)
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 16))

                        statsGrid
                        Text("Past flights")
                            .font(CEFont.body(14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.55))
                            .padding(.top, 8)

                        if store.completedSessions.isEmpty {
                            emptyState
                        } else {
                            ForEach(store.completedSessions) { session in
                                flightRow(session)
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard("Focus time", TimeFormatting.shortDuration(store.totalFocusSeconds))
            statCard("Flights", "\(store.completedSessions.count)")
            statCard("Distance", String(format: "%.0f km", store.totalKilometers))
            statCard("Longest", TimeFormatting.shortDuration(store.longestFlightSeconds))
            statCard("Streak", "\(store.currentStreakDays)d")
            statCard("Top route", store.favoriteRouteLabel)
        }
    }

    private func statCard(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(CEFont.body(12))
                .foregroundStyle(.white.opacity(0.5))
            Text(value)
                .font(CEFont.body(18, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func flightRow(_ session: FocusSession) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(CEColor.horizonTeal.opacity(0.2))
                Image(systemName: "airplane")
                    .foregroundStyle(CEColor.horizonTeal)
            }
            .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(session.route.originIATA) → \(session.route.destinationIATA)")
                    .font(CEFont.body(16, weight: .semibold))
                    .foregroundStyle(.white)
                Text("\(TimeFormatting.shortDuration(session.focusDurationSeconds)) · Seat \(session.seat.displayCode) · \(session.scenario.title)")
                    .font(CEFont.body(12))
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            Text("Completed")
                .font(CEFont.body(11, weight: .semibold))
                .foregroundStyle(CEColor.horizonTeal)
        }
        .padding(14)
        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "globe.europe.africa")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(.white.opacity(0.4))
            Text("No flights yet")
                .font(CEFont.body(16, weight: .semibold))
                .foregroundStyle(.white)
            Text("Complete a focus flight and it will appear here.")
                .font(CEFont.body(13))
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
