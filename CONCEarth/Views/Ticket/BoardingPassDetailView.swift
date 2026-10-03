import SwiftUI

struct BoardingPassDetailView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var store: SessionStore
    let sessionID: UUID

    private var session: FocusSession? {
        store.completedSessions.first { $0.id == sessionID }
    }

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    GlassCircleButton(systemName: "chevron.left") {
                        coordinator.openFlightLog()
                    }
                    Spacer()
                    Text("Boarding Pass")
                        .font(CEFont.body(16, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                if let session {
                    passCard(session)
                        .padding(.horizontal, 28)
                }

                Spacer()
            }
        }
    }

    private func passCard(_ session: FocusSession) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(CEBrand.name)
                .font(CEFont.body(12, weight: .bold))
                .foregroundStyle(CEColor.horizonTeal)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.route.originIATA)
                        .font(CEFont.display(34, weight: .bold))
                    Text(session.route.origin.city)
                        .font(CEFont.body(13))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                VStack(spacing: 4) {
                    Image(systemName: "airplane")
                    Text(TimeFormatting.minutesLabel(session.focusMinutes))
                        .font(CEFont.mono(11))
                        .foregroundStyle(.white.opacity(0.55))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(session.route.destinationIATA)
                        .font(CEFont.display(34, weight: .bold))
                    Text(session.route.destination.city)
                        .font(CEFont.body(13))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                field("Passenger", session.passengerName)
                field("Seat", session.seat.displayCode)
                field("Flight", session.route.flightNumber)
                field("Distance", String(format: "%.0f km", session.route.distanceKilometers))
                field("Focus", TimeFormatting.shortDuration(session.focusDurationSeconds))
                field("Date", dateString(session.endedAt ?? session.createdAt))
            }

            if session.hasPurpose {
                field("Purpose", session.focusPurpose)
            }
        }
        .padding(22)
        .background(Color(white: 0.12), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func field(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(CEFont.body(11))
                .foregroundStyle(.white.opacity(0.4))
            Text(value)
                .font(CEFont.body(15, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dateString(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy/MM/dd"
        return f.string(from: date)
    }
}
