import SwiftUI

struct LandingPhaseView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var settle: CGFloat = -24
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()
            LinearGradient(
                colors: [CEColor.nightBlue.opacity(0.5), CEColor.earthDeep],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()
                Image(systemName: "airplane.arrival")
                    .font(.system(size: 44, weight: .ultraLight))
                    .foregroundStyle(.white)
                    .offset(y: settle)
                    .opacity(opacity)

                Text("Landing")
                    .font(CEFont.display(28, weight: .bold))
                    .foregroundStyle(.white)
                    .opacity(opacity)

                if let route = coordinator.store.activeSession?.route
                    ?? coordinator.completedSessionForArrival?.route {
                    Text(route.destination.city)
                        .font(CEFont.body(16))
                        .foregroundStyle(.white.opacity(0.55))
                        .opacity(opacity)
                }
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { opacity = 1 }
            withAnimation(.easeInOut(duration: 1.8)) { settle = 0 }
        }
    }
}
