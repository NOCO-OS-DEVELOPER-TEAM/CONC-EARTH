import SwiftUI

struct TakeoffView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var lift: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()
            LinearGradient(
                colors: AtmosphereEngine.washColors(for: .sunrise) + [CEColor.earthDeep],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "airplane.departure")
                    .font(.system(size: 44, weight: .ultraLight))
                    .foregroundStyle(.white)
                    .offset(y: lift)
                    .opacity(opacity)

                Text("Takeoff")
                    .font(CEFont.display(28, weight: .bold))
                    .foregroundStyle(.white)
                    .opacity(opacity)

                if let route = coordinator.selectedRoute ?? coordinator.store.activeSession?.route {
                    Text("\(route.origin.city) → \(route.destination.city)")
                        .font(CEFont.body(15))
                        .foregroundStyle(.white.opacity(0.5))
                        .opacity(opacity)
                }
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { opacity = 1 }
            withAnimation(.easeInOut(duration: 2.6)) { lift = -36 }
        }
    }
}
