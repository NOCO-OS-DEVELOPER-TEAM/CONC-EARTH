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
        case .firstNightFlight: return "Erster Nachtflug"
        case .tenFlights: return "10 Flüge absolviert"
        case .fiveHoursFocused: return "5 Stunden fokussiert"
        case .firstLongHaul: return "Erster Langstreckenflug"
        case .sevenDayStreak: return "7-Tage-Serie"
        case .firstInternational: return "Erster internationaler Flug"
        case .firstWindowSeat: return "Erster Fensterplatz"
        case .firstThousandMiles: return "1.000 km geflogen"
        case .fiveThousandMiles: return "5.000 km geflogen"
        case .tenThousandMiles: return "10.000 km geflogen"
        }
    }

    var subtitle: String {
        switch self {
        case .firstNightFlight: return "Ruhige Nacht, tiefer Fokus."
        case .tenFlights: return "Die Reise wächst."
        case .fiveHoursFocused: return "Gut investierte Zeit."
        case .firstLongHaul: return "Ferne Horizonte."
        case .sevenDayStreak: return "Konstanz vor Intensität."
        case .firstInternational: return "Über eine Grenze."
        case .firstWindowSeat: return "Ein Blick, der bleibt."
        case .firstThousandMiles: return "Die Meilen beginnen."
        case .fiveThousandMiles: return "Die Welt wird größer."
        case .tenThousandMiles: return "Ein echter Reisender."
        }
    }
}

struct UnlockedAchievement: Identifiable, Codable, Hashable {
    var id: String { achievement.rawValue }
    let achievement: AchievementID
    let unlockedAt: Date
}
