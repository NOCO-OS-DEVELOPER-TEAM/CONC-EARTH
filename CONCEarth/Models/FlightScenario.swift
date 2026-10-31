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
        case .calm: return "Ruhiger Flug"
        case .night: return "Nachtflug"
        case .sunset: return "Sonnenuntergang"
        case .morning: return "Morgenflug"
        case .storm: return "Gewitterflug"
        case .longHaul: return "Langstrecke"
        }
    }

    var subtitle: String {
        switch self {
        case .calm: return "Ruhige Kabine. Gleichmäßiger Fokus."
        case .night: return "Dunkler Himmel. Tiefes Arbeiten."
        case .sunset: return "Goldenes Licht. Sanftes Tempo."
        case .morning: return "Klare Luft. Frischer Start."
        case .storm: return "Stimmung, aber ruhig."
        case .longHaul: return "Lange Sessions. Weite Horizonte."
        }
    }

    var recommendedMinutes: Int {
        switch self {
        case .calm: return 45
        case .night: return 60
        case .sunset: return 40
        case .morning: return 25
        case .storm: return 50
        case .longHaul: return 120
        }
    }
}
