import Foundation

enum FlightScenario: String, Codable, CaseIterable, Identifiable, Hashable {
    case calm
    case night
    case sunset
    case morning
    case storm
    case longHaul

    var id: String { rawValue }

    var title: String {
        switch self {
        case .calm: return "Calm Flight"
        case .night: return "Night Flight"
        case .sunset: return "Sunset Flight"
        case .morning: return "Morning Flight"
        case .storm: return "Storm Flight"
        case .longHaul: return "Long Haul"
        }
    }

    var subtitle: String {
        switch self {
        case .calm: return "Quiet cabin. Steady focus."
        case .night: return "Dark sky. Deep work."
        case .sunset: return "Golden light. Soft pace."
        case .morning: return "Clear air. Fresh start."
        case .storm: return "Moody atmosphere. Still calm."
        case .longHaul: return "Long sessions. Distant horizons."
        }
    }

    var recommendedMinutes: Int {
        switch self {
        case .calm: return 45
        case .night: return 60
        case .sunset: return 40
        case .morning: return 30
        case .storm: return 50
        case .longHaul: return 120
        }
    }
}
