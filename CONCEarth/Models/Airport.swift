import CoreLocation
import Foundation

struct Airport: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let city: String
    let country: String
    let iata: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}

enum AirportCatalog {
    static let all: [Airport] = [
        Airport(id: "HAM", name: "Hamburg Airport", city: "Hamburg", country: "Germany", iata: "HAM", latitude: 53.6304, longitude: 9.9882),
        Airport(id: "LHR", name: "Heathrow Airport", city: "London", country: "United Kingdom", iata: "LHR", latitude: 51.4700, longitude: -0.4543),
        Airport(id: "CDG", name: "Charles de Gaulle", city: "Paris", country: "France", iata: "CDG", latitude: 49.0097, longitude: 2.5479),
        Airport(id: "AMS", name: "Schiphol", city: "Amsterdam", country: "Netherlands", iata: "AMS", latitude: 52.3105, longitude: 4.7683),
        Airport(id: "MAD", name: "Adolfo Suárez Madrid–Barajas", city: "Madrid", country: "Spain", iata: "MAD", latitude: 40.4983, longitude: -3.5676),
        Airport(id: "FCO", name: "Leonardo da Vinci–Fiumicino", city: "Rome", country: "Italy", iata: "FCO", latitude: 41.8003, longitude: 12.2389),
        Airport(id: "JFK", name: "John F. Kennedy International", city: "New York", country: "United States", iata: "JFK", latitude: 40.6413, longitude: -73.7781),
        Airport(id: "HND", name: "Haneda Airport", city: "Tokyo", country: "Japan", iata: "HND", latitude: 35.5494, longitude: 139.7798)
    ]

    static func airport(iata: String) -> Airport? {
        all.first { $0.iata == iata }
    }

    static func nearest(to location: CLLocation) -> Airport {
        all.min(by: { $0.location.distance(from: location) < $1.location.distance(from: location) }) ?? all[0]
    }
}
