import SwiftUI

struct TakeMeSomewhereView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    private let options = [25, 45, 60, 90, 120]

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()
            RadialGradient(
                colors: [CEColor.nightBlue.opacity(0.55), .clear],
                center: .top,
                startRadius: 40,
                endRadius: 420
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    GlassCircleButton(systemName: "chevron.left") {
                        coordinator.backFromTakeMeSomewhere()
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                VStack(spacing: 12) {
                    Text("Take me somewhere")
                        .font(CEFont.display(30, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Text("Choose a focus duration.\nWe’ll find the route.")
                        .font(CEFont.body(15))
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 28)

                Spacer().frame(height: 36)

                HStack(spacing: 8) {
                    ForEach(options, id: \.self) { minutes in
                        Button {
                            coordinator.focusMinutes = minutes
                            coordinator.surpriseReveal = nil
                        } label: {
                            Text(TimeFormatting.minutesLabel(minutes))
                                .font(CEFont.mono(13, weight: .semibold))
                                .foregroundStyle(coordinator.focusMinutes == minutes ? CEColor.ink : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule().fill(coordinator.focusMinutes == minutes ? Color.white : Color.white.opacity(0.1))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer().frame(height: 28)

                if let route = coordinator.surpriseReveal {
                    VStack(spacing: 10) {
                        Text("Your destination")
                            .font(CEFont.body(12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.45))
                        Text(route.destination.displayTitle)
                            .font(CEFont.display(28, weight: .bold))
                            .foregroundStyle(.white)
                        Text("\(route.originIATA) → \(route.destinationIATA)")
                            .font(CEFont.body(15, weight: .medium))
                            .foregroundStyle(CEColor.horizonTeal)
                        Text(TimeFormatting.minutesLabel(coordinator.focusMinutes))
                            .font(CEFont.body(13))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer()

                if coordinator.surpriseReveal == nil {
                    PrimaryPillButton(title: "Find destination") {
                        coordinator.revealSurpriseDestination()
                    }
                    .padding(.horizontal, 28)
                } else {
                    PrimaryPillButton(title: "Start Flight") {
                        coordinator.startSurpriseFlight()
                    }
                    .padding(.horizontal, 28)
                }
            }
            .padding(.bottom, 28)
        }
    }
}
