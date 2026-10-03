import Foundation

enum AchievementID: String, Codable, CaseIterable, Identifiable, Hashable {
    case firstNightFlight
    case tenFlights
    case fiveHoursFocused
    case firstLongHaul
    case sevenDayStreak
    case firstInternational
    case firstWindowSeat
    case firstThousandMiles
    case fiveThousandMiles
    case tenThousandMiles

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstNightFlight: return "First Night Flight"
        case .tenFlights: return "10 Flights Completed"
        case .fiveHoursFocused: return "5 Hours Focused"
        case .firstLongHaul: return "First Long-Haul Flight"
        case .sevenDayStreak: return "7 Day Flight Streak"
        case .firstInternational: return "First International Flight"
        case .firstWindowSeat: return "First Window Seat Flight"
        case .firstThousandMiles: return "1,000 km flown"
        case .fiveThousandMiles: return "5,000 km flown"
        case .tenThousandMiles: return "10,000 km flown"
        }
    }

    var subtitle: String {
        switch self {
        case .firstNightFlight: return "Quiet skies, deep work."
        case .tenFlights: return "A growing journey."
        case .fiveHoursFocused: return "Time well spent."
        case .firstLongHaul: return "Distant horizons."
        case .sevenDayStreak: return "Consistency over intensity."
        case .firstInternational: return "Across a border."
        case .firstWindowSeat: return "A view worth keeping."
        case .firstThousandMiles: return "Flight miles begin."
        case .fiveThousandMiles: return "The world widens."
        case .tenThousandMiles: return "A serious traveler."
        }
    }
}

struct UnlockedAchievement: Identifiable, Codable, Hashable {
    var id: String { achievement.rawValue }
    let achievement: AchievementID
    let unlockedAt: Date
}
