import SwiftUI

struct JourneyView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var store: SessionStore
    @EnvironmentObject private var journey: JourneyStore

    private var snapshot: JourneySnapshot {
        journey.snapshot(from: store)
    }

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    GlassCircleButton(systemName: "chevron.left") {
                        coordinator.goHome()
                    }
                    Spacer()
                    Text("Your Journey")
                        .font(CEFont.body(17, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        summary
                        exploredButton
                        if !journey.achievements.isEmpty {
                            achievements
                        }
                        settings
                    }
                    .padding(20)
                }
            }
        }
    }

    private var summary: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Focus takes you somewhere.")
                .font(CEFont.body(14))
                .foregroundStyle(.white.opacity(0.5))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                quietStat("\(snapshot.destinations)", "destinations")
                quietStat(String(format: "%.0f km", snapshot.miles), "flight miles")
                quietStat("\(snapshot.flights)", "flights")
                quietStat(TimeFormatting.shortDuration(snapshot.focusSeconds), "focused")
                quietStat("\(snapshot.streak)d", "streak")
                quietStat("\(journey.unlockedAirports.count)", "airports")
            }
        }
    }

    private var exploredButton: some View {
        Button {
            coordinator.openWorld()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Explored World")
                        .font(CEFont.body(16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Open your personal map")
                        .font(CEFont.body(12))
                        .foregroundStyle(.white.opacity(0.45))
                }
                Spacer()
                Image(systemName: "globe.europe.africa")
                    .foregroundStyle(CEColor.horizonTeal)
            }
            .padding(16)
            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var achievements: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Milestones")
                .font(CEFont.body(13, weight: .medium))
                .foregroundStyle(.white.opacity(0.45))

            ForEach(journey.achievements.suffix(6).reversed()) { item in
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.achievement.title)
                        .font(CEFont.body(14, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(item.achievement.subtitle)
                        .font(CEFont.body(12))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.vertical, 6)
            }
        }
    }

    private var settings: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Traveler")
                .font(CEFont.body(13, weight: .medium))
                .foregroundStyle(.white.opacity(0.45))
            TextField("Name", text: $store.passengerName)
                .padding(12)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
            Toggle("Flight sounds", isOn: $store.soundsEnabled)
                .tint(CEColor.horizonTeal)
                .foregroundStyle(.white)
        }
        .padding(.top, 8)
    }

    private func quietStat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(CEFont.body(20, weight: .bold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(CEFont.body(12))
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
