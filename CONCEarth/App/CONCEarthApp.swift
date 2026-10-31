import SwiftUI

@main
struct CONCEarthApp: App {
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(coordinator)
                .environmentObject(coordinator.store)
                .environmentObject(coordinator.journey)
                .environmentObject(coordinator.learn)
                .environmentObject(coordinator.timer)
                .preferredColorScheme(.dark)
        }
    }
}
