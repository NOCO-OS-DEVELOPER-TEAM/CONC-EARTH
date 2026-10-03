import Foundation

enum SeatPosition: String, Codable, CaseIterable, Hashable {
    case window
    case middle
    case aisle

    var title: String {
        switch self {
        case .window: return "Window"
        case .middle: return "Middle"
        case .aisle: return "Aisle"
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
        case "B", "E": return .middle
        default: return .aisle
        }
    }

    var unlocksWindowView: Bool {
        position == .window
    }
}

enum SeatMapLayout {
    static let columns = ["A", "B", "C", "D", "E", "F"]
    static let rows = Array(1...8)

    static var allSeats: [Seat] {
        rows.flatMap { row in
            columns.map { Seat(row: row, letter: $0) }
        }
    }
}
