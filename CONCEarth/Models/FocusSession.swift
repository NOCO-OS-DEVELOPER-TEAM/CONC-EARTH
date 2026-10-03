import Foundation

enum SessionStatus: String, Codable, Hashable {
    case drafting
    case boarding
    case inFlight
    case paused
    case completed
    case cancelled
}

struct FocusSession: Identifiable, Codable, Hashable {
    var id: UUID
    var route: FlightRoute
    var seat: Seat
    var scenario: FlightScenario
    var passengerName: String
    var focusDurationSeconds: TimeInterval
    var startedAt: Date?
    var endedAt: Date?
    var accumulatedActiveSeconds: TimeInterval
    var lastResumeAt: Date?
    var status: SessionStatus
    var createdAt: Date

    init(
        id: UUID = UUID(),
        route: FlightRoute,
        seat: Seat,
        scenario: FlightScenario,
        passengerName: String = "Traveler",
        focusDurationSeconds: TimeInterval,
        startedAt: Date? = nil,
        endedAt: Date? = nil,
        accumulatedActiveSeconds: TimeInterval = 0,
        lastResumeAt: Date? = nil,
        status: SessionStatus = .drafting,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.route = route
        self.seat = seat
        self.scenario = scenario
        self.passengerName = passengerName
        self.focusDurationSeconds = focusDurationSeconds
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.accumulatedActiveSeconds = accumulatedActiveSeconds
        self.lastResumeAt = lastResumeAt
        self.status = status
        self.createdAt = createdAt
    }

    var focusMinutes: Int {
        Int(focusDurationSeconds / 60)
    }

    func elapsedActiveSeconds(at date: Date = Date()) -> TimeInterval {
        var total = accumulatedActiveSeconds
        if status == .inFlight, let resume = lastResumeAt {
            total += max(0, date.timeIntervalSince(resume))
        }
        return min(total, focusDurationSeconds)
    }

    func progress(at date: Date = Date()) -> Double {
        guard focusDurationSeconds > 0 else { return 0 }
        return min(1, max(0, elapsedActiveSeconds(at: date) / focusDurationSeconds))
    }

    func remainingSeconds(at date: Date = Date()) -> TimeInterval {
        max(0, focusDurationSeconds - elapsedActiveSeconds(at: date))
    }

    mutating func beginFlight(at date: Date = Date()) {
        startedAt = date
        lastResumeAt = date
        status = .inFlight
    }

    mutating func pause(at date: Date = Date()) {
        guard status == .inFlight else { return }
        accumulatedActiveSeconds = elapsedActiveSeconds(at: date)
        lastResumeAt = nil
        status = .paused
    }

    mutating func resume(at date: Date = Date()) {
        guard status == .paused else { return }
        lastResumeAt = date
        status = .inFlight
    }

    mutating func complete(at date: Date = Date()) {
        accumulatedActiveSeconds = focusDurationSeconds
        lastResumeAt = nil
        endedAt = date
        status = .completed
    }
}
