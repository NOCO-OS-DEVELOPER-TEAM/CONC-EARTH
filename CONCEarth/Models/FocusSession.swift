import Foundation

enum SessionStatus: String, Codable, Hashable {
    case drafting
    case boarding
    case takeoff
    case inFlight
    case paused
    case landing
    case completed
    case cancelled
}

struct FocusSession: Identifiable, Codable, Hashable {
    var id: UUID
    var route: FlightRoute
    var seat: Seat
    var scenario: FlightScenario
    var passengerName: String
    var focusPurpose: String
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
        focusPurpose: String = "",
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
        self.focusPurpose = focusPurpose
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

    var hasPurpose: Bool {
        !focusPurpose.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func elapsedActiveSeconds(at date: Date = Date()) -> TimeInterval {
        var total = accumulatedActiveSeconds
        if (status == .inFlight || status == .landing || status == .takeoff), let resume = lastResumeAt {
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

    func phase(at date: Date = Date()) -> FlightPhase {
        switch status {
        case .boarding: return .boarding
        case .takeoff: return .takeoff
        case .landing: return .landing
        case .completed: return .landed
        case .paused, .inFlight:
            return FlightPhase.cruiseOrLanding(
                progress: progress(at: date),
                remaining: remainingSeconds(at: date)
            )
        default:
            return .cruise
        }
    }

    mutating func beginTakeoff(at date: Date = Date()) {
        startedAt = date
        lastResumeAt = date
        status = .takeoff
    }

    mutating func enterCruise() {
        if status == .takeoff {
            status = .inFlight
        }
    }

    mutating func enterLanding() {
        if status == .inFlight || status == .paused {
            status = .landing
        }
    }

    mutating func beginFlight(at date: Date = Date()) {
        beginTakeoff(at: date)
    }

    mutating func pause(at date: Date = Date()) {
        guard status == .inFlight || status == .landing || status == .takeoff else { return }
        accumulatedActiveSeconds = elapsedActiveSeconds(at: date)
        lastResumeAt = nil
        status = .paused
    }

    mutating func resume(at date: Date = Date()) {
        guard status == .paused else { return }
        lastResumeAt = date
        let p = progress(at: date)
        status = p >= 0.93 ? .landing : .inFlight
    }

    mutating func complete(at date: Date = Date()) {
        accumulatedActiveSeconds = focusDurationSeconds
        lastResumeAt = nil
        endedAt = date
        status = .completed
    }

    enum CodingKeys: String, CodingKey {
        case id, route, seat, scenario, passengerName, focusPurpose
        case focusDurationSeconds, startedAt, endedAt
        case accumulatedActiveSeconds, lastResumeAt, status, createdAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        route = try c.decode(FlightRoute.self, forKey: .route)
        seat = try c.decode(Seat.self, forKey: .seat)
        scenario = try c.decode(FlightScenario.self, forKey: .scenario)
        passengerName = try c.decode(String.self, forKey: .passengerName)
        focusPurpose = try c.decodeIfPresent(String.self, forKey: .focusPurpose) ?? ""
        focusDurationSeconds = try c.decode(TimeInterval.self, forKey: .focusDurationSeconds)
        startedAt = try c.decodeIfPresent(Date.self, forKey: .startedAt)
        endedAt = try c.decodeIfPresent(Date.self, forKey: .endedAt)
        accumulatedActiveSeconds = try c.decode(TimeInterval.self, forKey: .accumulatedActiveSeconds)
        lastResumeAt = try c.decodeIfPresent(Date.self, forKey: .lastResumeAt)
        status = try c.decode(SessionStatus.self, forKey: .status)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}
