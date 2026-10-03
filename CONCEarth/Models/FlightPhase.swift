import Foundation

enum FlightPhase: String, Codable, Hashable {
    case boarding
    case takeoff
    case cruise
    case landing
    case landed

    var title: String {
        switch self {
        case .boarding: return "Boarding"
        case .takeoff: return "Takeoff"
        case .cruise: return "Cruise"
        case .landing: return "Landing"
        case .landed: return "Landed"
        }
    }

    static func cruiseOrLanding(progress: Double, remaining: TimeInterval) -> FlightPhase {
        if progress >= 0.93 || remaining <= 25 {
            return .landing
        }
        return .cruise
    }
}
