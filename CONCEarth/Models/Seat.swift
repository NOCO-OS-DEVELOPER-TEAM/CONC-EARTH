import Foundation

enum SeatPosition: String, Codable, CaseIterable, Hashable {
    case window
    case aisle

    var title: String {
        switch self {
        case .window: return "Fenster"
        case .aisle: return "Gang"
        }
    }
}

struct Seat: Identifiable, Codable, Hashable {
    let row: Int
    let letter: String

    var id: String { "\(String(format: "%02d", row))\(letter)" }
    var displayCode: String { id }

    var position: SeatPosition {
        switch letter {
        case "A", "F": return .window
        default: return .aisle
        }
    }

    var unlocksWindowView: Bool {
        position == .window
    }
}

enum SeatMapLayout {
    /// Focus-Flight-like 2-2 cabin: A C | D F
    static let leftColumns = ["A", "C"]
    static let rightColumns = ["D", "F"]
    static let rows = Array(1...5)
}
