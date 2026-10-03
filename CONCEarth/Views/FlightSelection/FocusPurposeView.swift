import SwiftUI

struct FocusPurposeView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    GlassCircleButton(systemName: "chevron.left") {
                        coordinator.backFromPurpose()
                    }
                    Spacer()
                    Button("Skip") {
                        coordinator.skipFocusPurpose()
                    }
                    .font(CEFont.body(14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                VStack(alignment: .leading, spacing: 18) {
                    Text("What are you focusing on?")
                        .font(CEFont.display(28, weight: .bold))
                        .foregroundStyle(.white)

                    TextField("e.g. Study math, write, deep work", text: $coordinator.focusPurpose)
                        .focused($focused)
                        .font(CEFont.body(17))
                        .foregroundStyle(.white)
                        .padding(.vertical, 14)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(.white.opacity(0.15))
                                .frame(height: 1)
                        }

                    if let route = coordinator.selectedRoute {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Focus destination")
                                .font(CEFont.body(12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.4))
                            Text(route.destination.displayTitle)
                                .font(CEFont.body(20, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("\(route.originIATA) → \(route.destinationIATA) · \(TimeFormatting.minutesLabel(coordinator.focusMinutes))")
                                .font(CEFont.body(13))
                                .foregroundStyle(CEColor.horizonTeal)
                            if coordinator.focusPurpose.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                                Text("Focus: \(coordinator.focusPurpose)")
                                    .font(CEFont.body(13))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                        .padding(.top, 12)
                    }
                }
                .padding(.horizontal, 28)

                Spacer()

                PrimaryPillButton(title: "Continue") {
                    coordinator.confirmFocusPurpose()
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 28)
            }
        }
        .onAppear { focused = true }
    }
}
