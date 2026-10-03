import SwiftUI

enum AtmosphereCondition: String, Codable, CaseIterable, Hashable {
    case clear
    case cloudy
    case rain
    case sunrise
    case day
    case sunset
    case night

    var title: String {
        switch self {
        case .clear: return "Clear"
        case .cloudy: return "Clouds"
        case .rain: return "Rain"
        case .sunrise: return "Sunrise"
        case .day: return "Day"
        case .sunset: return "Sunset"
        case .night: return "Night"
        }
    }

    var symbolName: String {
        switch self {
        case .clear: return "sun.max"
        case .cloudy: return "cloud.sun"
        case .rain: return "cloud.rain"
        case .sunrise: return "sunrise"
        case .day: return "sun.max"
        case .sunset: return "sunset"
        case .night: return "moon.stars"
        }
    }
}

enum AtmosphereEngine {
    /// Quiet progression for long sessions: morning → day → sunset/night.
    static func condition(
        scenario: FlightScenario,
        progress: Double,
        at date: Date = Date()
    ) -> AtmosphereCondition {
        if scenario == .storm {
            return progress < 0.5 ? .cloudy : .rain
        }
        if scenario == .night {
            return .night
        }

        // Scenario bias at start, then soft time evolution.
        let start: AtmosphereCondition
        switch scenario {
        case .morning: start = .sunrise
        case .sunset: start = .day
        case .calm: start = .clear
        case .longHaul: start = .day
        default: start = .clear
        }

        if progress < 0.25 { return start }
        if progress < 0.55 { return scenario == .morning || scenario == .calm ? .day : .cloudy }
        if progress < 0.82 {
            return scenario == .sunset ? .sunset : .day
        }
        if scenario == .sunset { return .sunset }

        let hour = Calendar.current.component(.hour, from: date)
        if hour >= 21 || hour < 5 { return .night }
        if hour >= 18 { return .sunset }
        return .clear
    }

    static func washColors(for condition: AtmosphereCondition) -> [Color] {
        switch condition {
        case .clear, .day:
            return [Color.orange.opacity(0.05), .clear]
        case .cloudy:
            return [Color.white.opacity(0.08), Color.black.opacity(0.12)]
        case .rain:
            return [CEColor.stormSlate.opacity(0.28), Color.black.opacity(0.18)]
        case .sunrise:
            return [Color.orange.opacity(0.18), Color.pink.opacity(0.08), .clear]
        case .sunset:
            return [CEColor.duskOrange.opacity(0.22), CEColor.nightBlue.opacity(0.15), .clear]
        case .night:
            return [CEColor.nightBlue.opacity(0.35), Color.black.opacity(0.25)]
        }
    }
}
