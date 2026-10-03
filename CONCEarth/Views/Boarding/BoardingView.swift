import SwiftUI

struct BoardingView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var phase: Int = 0

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()
            scenarioAtmosphere
                .ignoresSafeArea()
                .blur(radius: 28)
                .opacity(0.85)

            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "airplane.departure")
                    .font(.system(size: 42, weight: .light))
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse, options: .repeating, value: phase)
                    .opacity(phase >= 1 ? 1 : 0)
                    .offset(y: phase >= 1 ? 0 : 16)

                VStack(spacing: 8) {
                    Text(phaseText)
                        .font(CEFont.display(26, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    if let route = coordinator.selectedRoute {
                        Text("\(route.origin.city) → \(route.destination.city)")
                            .font(CEFont.body(15))
                            .foregroundStyle(.white.opacity(0.55))
                    }
                }
                .padding(.horizontal, 28)

                Spacer()

                PrimaryPillButton(title: "GO") {
                    coordinator.launchFlight()
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 28)
                .opacity(phase >= 3 ? 1 : 0.35)
                .disabled(phase < 3)
            }
        }
        .onAppear { runSequence() }
    }

    private var phaseText: String {
        switch phase {
        case 0: return "Preparing cabin…"
        case 1: return "Cabin doors closed,"
        case 2: return "Ready for departure."
        default: return "Ready for departure."
        }
    }

    private var scenarioAtmosphere: some View {
        Group {
            switch coordinator.selectedScenario {
            case .night:
                LinearGradient(colors: [CEColor.nightBlue, .black], startPoint: .top, endPoint: .bottom)
            case .sunset:
                LinearGradient(colors: [CEColor.duskOrange, CEColor.nightBlue], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .morning:
                LinearGradient(colors: [Color(red: 0.55, green: 0.75, blue: 0.95), CEColor.horizonTeal.opacity(0.5)], startPoint: .top, endPoint: .bottom)
            case .storm:
                LinearGradient(colors: [CEColor.stormSlate, CEColor.earthDeep], startPoint: .top, endPoint: .bottom)
            case .longHaul:
                LinearGradient(colors: [CEColor.nightBlue, CEColor.horizonTeal.opacity(0.35)], startPoint: .topLeading, endPoint: .bottomTrailing)
            case .calm:
                LinearGradient(colors: [Color(white: 0.18), CEColor.earthDeep], startPoint: .top, endPoint: .bottom)
            }
        }
    }

    private func runSequence() {
        withAnimation(.easeOut(duration: 0.4)) { phase = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.easeOut(duration: 0.35)) { phase = 2 }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) { phase = 3 }
        }
    }
}
