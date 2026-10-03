import Foundation

struct FlightRoute: Identifiable, Codable, Hashable {
    let id: String
    let originIATA: String
    let destinationIATA: String
    let flightNumber: String
    let aircraftType: String

    var origin: Airport { AirportCatalog.airport(iata: originIATA)! }
    var destination: Airport { AirportCatalog.airport(iata: destinationIATA)! }

    var distanceKilometers: Double {
        RouteGeometry.distanceKilometers(from: origin.coordinate, to: destination.coordinate)
    }

    var suggestedFocusMinutes: Int {
        // Map real-world distance into focus session ranges.
        let km = distanceKilometers
        switch km {
        case ..<500: return 25
        case ..<1200: return 45
        case ..<3500: return 60
        case ..<7000: return 90
        default: return 120
        }
    }
}

enum RouteCatalog {
    /// Expandable connection graph between the seed airports.
    static let connections: [FlightRoute] = [
        FlightRoute(id: "CE101", originIATA: "HAM", destinationIATA: "LHR", flightNumber: "CE101", aircraftType: "A320neo"),
        FlightRoute(id: "CE102", originIATA: "HAM", destinationIATA: "CDG", flightNumber: "CE102", aircraftType: "A220"),
        FlightRoute(id: "CE103", originIATA: "HAM", destinationIATA: "AMS", flightNumber: "CE103", aircraftType: "E195"),
        FlightRoute(id: "CE104", originIATA: "LHR", destinationIATA: "JFK", flightNumber: "CE104", aircraftType: "B787-9"),
        FlightRoute(id: "CE105", originIATA: "CDG", destinationIATA: "FCO", flightNumber: "CE105", aircraftType: "A321"),
        FlightRoute(id: "CE106", originIATA: "AMS", destinationIATA: "MAD", flightNumber: "CE106", aircraftType: "A320"),
        FlightRoute(id: "CE107", originIATA: "MAD", destinationIATA: "FCO", flightNumber: "CE107", aircraftType: "A319"),
        FlightRoute(id: "CE108", originIATA: "LHR", destinationIATA: "CDG", flightNumber: "CE108", aircraftType: "A320"),
        FlightRoute(id: "CE109", originIATA: "JFK", destinationIATA: "LHR", flightNumber: "CE109", aircraftType: "B777-300ER"),
        FlightRoute(id: "CE110", originIATA: "HND", destinationIATA: "JFK", flightNumber: "CE110", aircraftType: "B787-10"),
        FlightRoute(id: "CE111", originIATA: "FCO", destinationIATA: "AMS", flightNumber: "CE111", aircraftType: "A320"),
        FlightRoute(id: "CE112", originIATA: "CDG", destinationIATA: "JFK", flightNumber: "CE112", aircraftType: "A350-900")
    ]

    static func routes(from iata: String) -> [FlightRoute] {
        connections.filter { $0.originIATA == iata }
    }

    static func routes(reachableWithinMinutes minutes: Int, from iata: String) -> [FlightRoute] {
        routes(from: iata).filter { route in
            // Soft matching: any route can be flown at the chosen focus duration.
            // Preferred routes cluster near the duration suggestion.
            abs(route.suggestedFocusMinutes - minutes) <= 60 || minutes >= 20
        }
        .sorted { abs($0.suggestedFocusMinutes - minutes) < abs($1.suggestedFocusMinutes - minutes) }
    }
}
