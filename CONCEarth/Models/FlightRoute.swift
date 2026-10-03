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

    var isInternational: Bool {
        origin.countryCode != destination.countryCode
    }

    var isLongHaul: Bool {
        distanceKilometers >= 3500
    }

    var suggestedFocusMinutes: Int {
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
        FlightRoute(id: "CE112", originIATA: "CDG", destinationIATA: "JFK", flightNumber: "CE112", aircraftType: "A350-900"),
        FlightRoute(id: "CE113", originIATA: "HAM", destinationIATA: "BER", flightNumber: "CE113", aircraftType: "A319"),
        FlightRoute(id: "CE114", originIATA: "HAM", destinationIATA: "MUC", flightNumber: "CE114", aircraftType: "A320"),
        FlightRoute(id: "CE115", originIATA: "LHR", destinationIATA: "DUB", flightNumber: "CE115", aircraftType: "A320"),
        FlightRoute(id: "CE116", originIATA: "CDG", destinationIATA: "ZRH", flightNumber: "CE116", aircraftType: "A220"),
        FlightRoute(id: "CE117", originIATA: "AMS", destinationIATA: "CPH", flightNumber: "CE117", aircraftType: "E195"),
        FlightRoute(id: "CE118", originIATA: "FCO", destinationIATA: "ATH", flightNumber: "CE118", aircraftType: "A320"),
        FlightRoute(id: "CE119", originIATA: "MAD", destinationIATA: "LIS", flightNumber: "CE119", aircraftType: "A320"),
        FlightRoute(id: "CE120", originIATA: "LHR", destinationIATA: "DXB", flightNumber: "CE120", aircraftType: "A380"),
        FlightRoute(id: "CE121", originIATA: "CDG", destinationIATA: "SIN", flightNumber: "CE121", aircraftType: "A350-900"),
        FlightRoute(id: "CE122", originIATA: "JFK", destinationIATA: "LAX", flightNumber: "CE122", aircraftType: "B787-9"),
        FlightRoute(id: "CE123", originIATA: "HND", destinationIATA: "SIN", flightNumber: "CE123", aircraftType: "B787-10"),
        FlightRoute(id: "CE124", originIATA: "DXB", destinationIATA: "SIN", flightNumber: "CE124", aircraftType: "B777-300ER"),
        FlightRoute(id: "CE125", originIATA: "SIN", destinationIATA: "SYD", flightNumber: "CE125", aircraftType: "A350-900"),
        FlightRoute(id: "CE126", originIATA: "LAX", destinationIATA: "HND", flightNumber: "CE126", aircraftType: "B787-9"),
        FlightRoute(id: "CE127", originIATA: "IST", destinationIATA: "DXB", flightNumber: "CE127", aircraftType: "A321neo"),
        FlightRoute(id: "CE128", originIATA: "VIE", destinationIATA: "IST", flightNumber: "CE128", aircraftType: "A320"),
        FlightRoute(id: "CE129", originIATA: "BER", destinationIATA: "ATH", flightNumber: "CE129", aircraftType: "A320"),
        FlightRoute(id: "CE130", originIATA: "CPH", destinationIATA: "OSL", flightNumber: "CE130", aircraftType: "A220"),
        FlightRoute(id: "CE131", originIATA: "MUC", destinationIATA: "VIE", flightNumber: "CE131", aircraftType: "A319"),
        FlightRoute(id: "CE132", originIATA: "ZRH", destinationIATA: "LIS", flightNumber: "CE132", aircraftType: "A220"),
        FlightRoute(id: "CE133", originIATA: "YYZ", destinationIATA: "LHR", flightNumber: "CE133", aircraftType: "B787-9"),
        FlightRoute(id: "CE134", originIATA: "SFO", destinationIATA: "JFK", flightNumber: "CE134", aircraftType: "A321"),
        FlightRoute(id: "CE135", originIATA: "DOH", destinationIATA: "SIN", flightNumber: "CE135", aircraftType: "A350-1000"),
        FlightRoute(id: "CE136", originIATA: "ICN", destinationIATA: "HND", flightNumber: "CE136", aircraftType: "A321neo"),
        FlightRoute(id: "CE137", originIATA: "HKG", destinationIATA: "SIN", flightNumber: "CE137", aircraftType: "A350-900"),
        FlightRoute(id: "CE138", originIATA: "SYD", destinationIATA: "AKL", flightNumber: "CE138", aircraftType: "B787-9"),
        FlightRoute(id: "CE139", originIATA: "JNB", destinationIATA: "DXB", flightNumber: "CE139", aircraftType: "B777-300ER"),
        FlightRoute(id: "CE140", originIATA: "CAI", destinationIATA: "FCO", flightNumber: "CE140", aircraftType: "A320")
    ]

    static func routes(from iata: String) -> [FlightRoute] {
        connections.filter { $0.originIATA == iata }
    }

    static func routes(from iata: String, unlocked: Set<String>) -> [FlightRoute] {
        routes(from: iata).filter { unlocked.contains($0.destinationIATA) && unlocked.contains($0.originIATA) }
    }

    static func routes(reachableWithinMinutes minutes: Int, from iata: String, unlocked: Set<String>) -> [FlightRoute] {
        routes(from: iata, unlocked: unlocked)
            .sorted { abs($0.suggestedFocusMinutes - minutes) < abs($1.suggestedFocusMinutes - minutes) }
    }

    static func surpriseRoute(minutes: Int, from iata: String, unlocked: Set<String>) -> FlightRoute? {
        let candidates = routes(from: iata, unlocked: unlocked)
        let pool: [FlightRoute]
        if candidates.isEmpty {
            pool = connections.filter { unlocked.contains($0.originIATA) && unlocked.contains($0.destinationIATA) }
        } else {
            pool = candidates
        }
        guard !pool.isEmpty else { return nil }

        let band: ClosedRange<Double>
        switch minutes {
        case ..<35: band = 0...900
        case ..<75: band = 400...2500
        case ..<100: band = 1500...5500
        default: band = 3000...20_000
        }

        let matched = pool.filter { band.contains($0.distanceKilometers) }
        return (matched.isEmpty ? pool : matched).randomElement()
    }
}
