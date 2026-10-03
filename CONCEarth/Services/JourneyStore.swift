import Combine
import Foundation

struct JourneySnapshot {
    let destinations: Int
    let kilometers: Double
    let flights: Int
    let focusSeconds: TimeInterval
    let streak: Int
    let miles: Double
}

@MainActor
final class JourneyStore: ObservableObject {
    @Published private(set) var unlockedAirportIATAs: Set<String>
    @Published private(set) var achievements: [UnlockedAchievement] = []
    @Published var pendingUnlockAirport: Airport?
    @Published var pendingAchievement: AchievementID?

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let unlocked = "ce.unlockedAirports"
        static let achievements = "ce.achievements"
    }

    init() {
        if let saved = defaults.stringArray(forKey: Keys.unlocked) {
            unlockedAirportIATAs = Set(saved).union(AirportCatalog.starterIATAs)
        } else {
            unlockedAirportIATAs = AirportCatalog.starterIATAs
        }
        persistUnlocked()

        if let data = defaults.data(forKey: Keys.achievements),
           let decoded = try? JSONDecoder().decode([UnlockedAchievement].self, from: data) {
            achievements = decoded
        }
    }

    var unlockedAirports: [Airport] {
        AirportCatalog.unlocked(from: unlockedAirportIATAs)
    }

    func isUnlocked(_ iata: String) -> Bool {
        unlockedAirportIATAs.contains(iata)
    }

    func snapshot(from store: SessionStore) -> JourneySnapshot {
        JourneySnapshot(
            destinations: exploredDestinations(from: store).count,
            kilometers: store.totalKilometers,
            flights: store.completedSessions.count,
            focusSeconds: store.totalFocusSeconds,
            streak: store.currentStreakDays,
            miles: store.totalKilometers
        )
    }

    func exploredDestinations(from store: SessionStore) -> [Airport] {
        let codes = Set(store.completedSessions.map(\.route.destinationIATA))
        return codes.compactMap { AirportCatalog.airport(iata: $0) }
            .sorted { $0.city < $1.city }
    }

    func completedRoutes(from store: SessionStore) -> [FlightRoute] {
        var seen = Set<String>()
        var routes: [FlightRoute] = []
        for session in store.completedSessions {
            let key = "\(session.route.originIATA)-\(session.route.destinationIATA)"
            if seen.insert(key).inserted {
                routes.append(session.route)
            }
        }
        return routes
    }

    /// One calm unlock moment per completed flight.
    func processCompletion(session: FocusSession, store: SessionStore) {
        let destination = session.route.destination
        if !unlockedAirportIATAs.contains(destination.iata) {
            unlockedAirportIATAs.insert(destination.iata)
            pendingUnlockAirport = destination
        } else if let next = nextCandidate(for: store) {
            unlockedAirportIATAs.insert(next.iata)
            pendingUnlockAirport = next
        }

        evaluateAchievements(after: session, store: store)
        persist()
    }

    func consumePendingUnlock() {
        pendingUnlockAirport = nil
    }

    func consumePendingAchievement() {
        pendingAchievement = nil
    }

    private func nextCandidate(for store: SessionStore) -> Airport? {
        let tier = currentTier(for: store)
        return AirportCatalog.all
            .filter { $0.unlockTier > 0 && $0.unlockTier <= tier && !unlockedAirportIATAs.contains($0.iata) }
            .sorted { lhs, rhs in
                if lhs.unlockTier != rhs.unlockTier { return lhs.unlockTier < rhs.unlockTier }
                return lhs.city < rhs.city
            }
            .first
    }

    private func currentTier(for store: SessionStore) -> Int {
        let flights = store.completedSessions.count
        let km = store.totalKilometers
        if flights >= 10 || km >= 10_000 { return 3 }
        if flights >= 5 || km >= 4_000 { return 2 }
        if flights >= 1 || km >= 300 { return 1 }
        return 0
    }

    private func evaluateAchievements(after session: FocusSession, store: SessionStore) {
        var earned: [AchievementID] = []
        let owned = Set(achievements.map(\.achievement))

        func award(_ id: AchievementID) {
            guard !owned.contains(id), !earned.contains(id) else { return }
            earned.append(id)
        }

        if session.scenario == .night { award(.firstNightFlight) }
        if store.completedSessions.count >= 10 { award(.tenFlights) }
        if store.totalFocusSeconds >= 5 * 3600 { award(.fiveHoursFocused) }
        if session.route.isLongHaul || session.scenario == .longHaul { award(.firstLongHaul) }
        if store.currentStreakDays >= 7 { award(.sevenDayStreak) }
        if session.route.isInternational { award(.firstInternational) }
        if session.seat.unlocksWindowView { award(.firstWindowSeat) }
        if store.totalKilometers >= 1_000 { award(.firstThousandMiles) }
        if store.totalKilometers >= 5_000 { award(.fiveThousandMiles) }
        if store.totalKilometers >= 10_000 { award(.tenThousandMiles) }

        guard let first = earned.first else { return }
        let now = Date()
        for id in earned {
            achievements.append(UnlockedAchievement(achievement: id, unlockedAt: now))
        }
        pendingAchievement = first
    }

    private func persist() {
        persistUnlocked()
        if let data = try? JSONEncoder().encode(achievements) {
            defaults.set(data, forKey: Keys.achievements)
        }
    }

    private func persistUnlocked() {
        defaults.set(Array(unlockedAirportIATAs), forKey: Keys.unlocked)
    }
}
