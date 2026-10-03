import SwiftUI
import UIKit

struct ArrivalView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var journey: JourneyStore

    @State private var showUnlock = false
    @State private var showAchievement = false
    @State private var contentOpacity = 0.0

    private var flight: FocusSession? {
        coordinator.completedSessionForArrival
    }

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()
            LinearGradient(
                colors: [Color.white.opacity(0.06), .clear, CEColor.earthDeep],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer()

                Text("Landed")
                    .font(CEFont.display(34, weight: .bold))
                    .foregroundStyle(.white)

                if let flight {
                    Text("\(flight.route.destination.city) reached.")
                        .font(CEFont.body(17))
                        .foregroundStyle(.white.opacity(0.6))

                    Text("\(TimeFormatting.shortDuration(flight.focusDurationSeconds)) focused")
                        .font(CEFont.body(14, weight: .medium))
                        .foregroundStyle(CEColor.horizonTeal)
                        .padding(.top, 2)

                    if flight.hasPurpose {
                        Text("Focus: \(flight.focusPurpose)")
                            .font(CEFont.body(13))
                            .foregroundStyle(.white.opacity(0.45))
                            .padding(.top, 4)
                    }
                }

                Spacer()

                PrimaryPillButton(title: "Done") {
                    coordinator.dismissArrival()
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 28)
            }
            .opacity(contentOpacity)

            if showUnlock, let airport = journey.pendingUnlockAirport {
                DestinationUnlockToast(airport: airport)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .onAppear {
                        let generator = UIImpactFeedbackGenerator(style: .soft)
                        generator.impactOccurred()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                            withAnimation(.easeOut(duration: 0.35)) {
                                showUnlock = false
                            }
                            journey.consumePendingUnlock()
                            presentAchievementIfNeeded()
                        }
                    }
            }

            if showAchievement, let achievement = journey.pendingAchievement {
                VStack {
                    Spacer()
                    AchievementToast(achievement: achievement)
                        .padding(.bottom, 110)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showAchievement = false
                        }
                        journey.consumePendingAchievement()
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) { contentOpacity = 1 }
            if journey.pendingUnlockAirport != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        showUnlock = true
                    }
                }
            } else {
                presentAchievementIfNeeded()
            }
        }
    }

    private func presentAchievementIfNeeded() {
        guard journey.pendingAchievement != nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeOut(duration: 0.35)) {
                showAchievement = true
            }
        }
    }
}
