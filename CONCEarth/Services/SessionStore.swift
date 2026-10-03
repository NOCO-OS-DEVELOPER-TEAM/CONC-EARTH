import Foundation
import SwiftUI

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var sessions: [FocusSession] = []
    @Published var activeSession: FocusSession?
    @Published var passengerName: String {
        didSet { UserDefaults.standard.set(passengerName, forKey: Keys.passengerName) }
    }
    @Published var soundsEnabled: Bool {
        didSet { UserDefaults.standard.set(soundsEnabled, forKey: Keys.soundsEnabled) }
    }
    @Published var homeAirportIATA: String {
        didSet { UserDefaults.standard.set(homeAirportIATA, forKey: Keys.homeAirport) }
    }

    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Keys {
        static let passengerName = "ce.passengerName"
        static let soundsEnabled = "ce.soundsEnabled"
        static let homeAirport = "ce.homeAirport"
        static let activeSession = "ce.activeSession"
    }

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        fileURL = docs.appendingPathComponent("flightlog.json")
        passengerName = UserDefaults.standard.string(forKey: Keys.passengerName) ?? "Traveler"
        soundsEnabled = UserDefaults.standard.object(forKey: Keys.soundsEnabled) as? Bool ?? true
        homeAirportIATA = UserDefaults.standard.string(forKey: Keys.homeAirport) ?? "HAM"
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        load()
        restoreActiveSession()
    }

    var homeAirport: Airport {
        AirportCatalog.airport(iata: homeAirportIATA) ?? AirportCatalog.all[0]
    }

    var completedSessions: [FocusSession] {
        sessions.filter { $0.status == .completed }.sorted { ($0.endedAt ?? $0.createdAt) > ($1.endedAt ?? $1.createdAt) }
    }

    var totalFocusSeconds: TimeInterval {
        completedSessions.reduce(0) { $0 + $1.focusDurationSeconds }
    }

    var totalKilometers: Double {
        completedSessions.reduce(0) { $0 + $1.route.distanceKilometers }
    }

    var longestFlightSeconds: TimeInterval {
        completedSessions.map(\.focusDurationSeconds).max() ?? 0
    }

    var currentStreakDays: Int {
        let days = Set(completedSessions.compactMap { session -> String? in
            guard let end = session.endedAt else { return nil }
            return dayKey(end)
        })
        var streak = 0
        var cursor = Date()
        while days.contains(dayKey(cursor)) {
            streak += 1
            cursor = Calendar.current.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }
        return streak
    }

    var favoriteRouteLabel: String {
        let groups = Dictionary(grouping: completedSessions, by: { "\($0.route.originIATA) → \($0.route.destinationIATA)" })
        return groups.max(by: { $0.value.count < $1.value.count })?.key ?? "—"
    }

    func setHomeAirport(_ airport: Airport) {
        homeAirportIATA = airport.iata
    }

    func saveDraft(_ session: FocusSession) {
        activeSession = session
        persistActive()
    }

    func updateActive(_ mutate: (inout FocusSession) -> Void) {
        guard var session = activeSession else { return }
        mutate(&session)
        activeSession = session
        persistActive()
        if session.status == .completed {
            upsert(session)
            clearActive()
        }
    }

    func upsert(_ session: FocusSession) {
        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[idx] = session
        } else {
            sessions.insert(session, at: 0)
        }
        persistLog()
    }

    func clearActive() {
        activeSession = nil
        UserDefaults.standard.removeObject(forKey: Keys.activeSession)
    }

    private func restoreActiveSession() {
        guard let data = UserDefaults.standard.data(forKey: Keys.activeSession),
              var session = try? decoder.decode(FocusSession.self, from: data) else { return }

        // Reconstruct progress after relaunch.
        if session.status == .inFlight || session.status == .paused {
            let progress = session.progress()
            if progress >= 1 {
                session.complete()
                upsert(session)
                clearActive()
                return
            }
            activeSession = session
        } else if session.status == .boarding || session.status == .drafting {
            activeSession = session
        }
    }

    private func persistActive() {
        guard let session = activeSession,
              let data = try? encoder.encode(session) else { return }
        UserDefaults.standard.set(data, forKey: Keys.activeSession)
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let decoded = try? decoder.decode([FocusSession].self, from: data) else {
            sessions = []
            return
        }
        sessions = decoded
    }

    private func persistLog() {
        guard let data = try? encoder.encode(sessions) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func dayKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar.current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }
}
