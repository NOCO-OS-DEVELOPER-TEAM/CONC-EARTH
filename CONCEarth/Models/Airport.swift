import CoreLocation
import Foundation

struct Airport: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let city: String
    let country: String
    let countryCode: String
    let iata: String
    let latitude: Double
    let longitude: Double
    /// 0 = available at start. Higher tiers unlock through journey progress.
    let unlockTier: Int

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    var flagEmoji: String {
        CountryFlag.emoji(for: countryCode)
    }

    var displayTitle: String {
        "\(city) \(flagEmoji)"
    }
}

enum CountryFlag {
    static func emoji(for countryCode: String) -> String {
        let code = countryCode.uppercased()
        guard code.count == 2 else { return "🌍" }
        let scalars = code.unicodeScalars.compactMap { UnicodeScalar(127397 + $0.value) }
        return String(String.UnicodeScalarView(scalars))
    }
}

/// Expandable catalog — designed for hundreds of airports without UI changes.
enum AirportCatalog {
    static let starterIATAs: Set<String> = ["HAM", "LHR", "CDG", "AMS", "MAD", "FCO", "JFK", "HND"]

    static let all: [Airport] = [
        // Starter (tier 0)
        Airport(id: "HAM", name: "Hamburg Airport", city: "Hamburg", country: "Germany", countryCode: "DE", iata: "HAM", latitude: 53.6304, longitude: 9.9882, unlockTier: 0),
        Airport(id: "LHR", name: "Heathrow Airport", city: "London", country: "United Kingdom", countryCode: "GB", iata: "LHR", latitude: 51.4700, longitude: -0.4543, unlockTier: 0),
        Airport(id: "CDG", name: "Charles de Gaulle", city: "Paris", country: "France", countryCode: "FR", iata: "CDG", latitude: 49.0097, longitude: 2.5479, unlockTier: 0),
        Airport(id: "AMS", name: "Schiphol", city: "Amsterdam", country: "Netherlands", countryCode: "NL", iata: "AMS", latitude: 52.3105, longitude: 4.7683, unlockTier: 0),
        Airport(id: "MAD", name: "Adolfo Suárez Madrid–Barajas", city: "Madrid", country: "Spain", countryCode: "ES", iata: "MAD", latitude: 40.4983, longitude: -3.5676, unlockTier: 0),
        Airport(id: "FCO", name: "Leonardo da Vinci–Fiumicino", city: "Rome", country: "Italy", countryCode: "IT", iata: "FCO", latitude: 41.8003, longitude: 12.2389, unlockTier: 0),
        Airport(id: "JFK", name: "John F. Kennedy International", city: "New York", country: "United States", countryCode: "US", iata: "JFK", latitude: 40.6413, longitude: -73.7781, unlockTier: 0),
        Airport(id: "HND", name: "Haneda Airport", city: "Tokyo", country: "Japan", countryCode: "JP", iata: "HND", latitude: 35.5494, longitude: 139.7798, unlockTier: 0),

        // Tier 1 — early unlocks
        Airport(id: "BER", name: "Berlin Brandenburg", city: "Berlin", country: "Germany", countryCode: "DE", iata: "BER", latitude: 52.3667, longitude: 13.5033, unlockTier: 1),
        Airport(id: "MUC", name: "Munich Airport", city: "Munich", country: "Germany", countryCode: "DE", iata: "MUC", latitude: 48.3538, longitude: 11.7861, unlockTier: 1),
        Airport(id: "ZRH", name: "Zurich Airport", city: "Zurich", country: "Switzerland", countryCode: "CH", iata: "ZRH", latitude: 47.4647, longitude: 8.5492, unlockTier: 1),
        Airport(id: "VIE", name: "Vienna International", city: "Vienna", country: "Austria", countryCode: "AT", iata: "VIE", latitude: 48.1103, longitude: 16.5697, unlockTier: 1),
        Airport(id: "CPH", name: "Copenhagen Airport", city: "Copenhagen", country: "Denmark", countryCode: "DK", iata: "CPH", latitude: 55.6180, longitude: 12.6560, unlockTier: 1),
        Airport(id: "OSL", name: "Oslo Gardermoen", city: "Oslo", country: "Norway", countryCode: "NO", iata: "OSL", latitude: 60.1939, longitude: 11.1004, unlockTier: 1),
        Airport(id: "ARN", name: "Stockholm Arlanda", city: "Stockholm", country: "Sweden", countryCode: "SE", iata: "ARN", latitude: 59.6519, longitude: 17.9186, unlockTier: 1),
        Airport(id: "DUB", name: "Dublin Airport", city: "Dublin", country: "Ireland", countryCode: "IE", iata: "DUB", latitude: 53.4213, longitude: -6.2701, unlockTier: 1),
        Airport(id: "LIS", name: "Lisbon Humberto Delgado", city: "Lisbon", country: "Portugal", countryCode: "PT", iata: "LIS", latitude: 38.7742, longitude: -9.1342, unlockTier: 1),
        Airport(id: "ATH", name: "Athens International", city: "Athens", country: "Greece", countryCode: "GR", iata: "ATH", latitude: 37.9364, longitude: 23.9445, unlockTier: 1),

        // Tier 2
        Airport(id: "IST", name: "Istanbul Airport", city: "Istanbul", country: "Turkey", countryCode: "TR", iata: "IST", latitude: 41.2753, longitude: 28.7519, unlockTier: 2),
        Airport(id: "DXB", name: "Dubai International", city: "Dubai", country: "United Arab Emirates", countryCode: "AE", iata: "DXB", latitude: 25.2532, longitude: 55.3657, unlockTier: 2),
        Airport(id: "DOH", name: "Hamad International", city: "Doha", country: "Qatar", countryCode: "QA", iata: "DOH", latitude: 25.2731, longitude: 51.6081, unlockTier: 2),
        Airport(id: "CAI", name: "Cairo International", city: "Cairo", country: "Egypt", countryCode: "EG", iata: "CAI", latitude: 30.1219, longitude: 31.4056, unlockTier: 2),
        Airport(id: "GRU", name: "São Paulo–Guarulhos", city: "São Paulo", country: "Brazil", countryCode: "BR", iata: "GRU", latitude: -23.4356, longitude: -46.4731, unlockTier: 2),
        Airport(id: "YYZ", name: "Toronto Pearson", city: "Toronto", country: "Canada", countryCode: "CA", iata: "YYZ", latitude: 43.6777, longitude: -79.6248, unlockTier: 2),
        Airport(id: "LAX", name: "Los Angeles International", city: "Los Angeles", country: "United States", countryCode: "US", iata: "LAX", latitude: 33.9416, longitude: -118.4085, unlockTier: 2),
        Airport(id: "SFO", name: "San Francisco International", city: "San Francisco", country: "United States", countryCode: "US", iata: "SFO", latitude: 37.6213, longitude: -122.3790, unlockTier: 2),

        // Tier 3 — distant horizons
        Airport(id: "SIN", name: "Singapore Changi", city: "Singapore", country: "Singapore", countryCode: "SG", iata: "SIN", latitude: 1.3644, longitude: 103.9915, unlockTier: 3),
        Airport(id: "HKG", name: "Hong Kong International", city: "Hong Kong", country: "Hong Kong", countryCode: "HK", iata: "HKG", latitude: 22.3080, longitude: 113.9185, unlockTier: 3),
        Airport(id: "ICN", name: "Incheon International", city: "Seoul", country: "South Korea", countryCode: "KR", iata: "ICN", latitude: 37.4602, longitude: 126.4407, unlockTier: 3),
        Airport(id: "SYD", name: "Sydney Kingsford Smith", city: "Sydney", country: "Australia", countryCode: "AU", iata: "SYD", latitude: -33.9399, longitude: 151.1753, unlockTier: 3),
        Airport(id: "AKL", name: "Auckland Airport", city: "Auckland", country: "New Zealand", countryCode: "NZ", iata: "AKL", latitude: -37.0082, longitude: 174.7850, unlockTier: 3),
        Airport(id: "JNB", name: "O. R. Tambo International", city: "Johannesburg", country: "South Africa", countryCode: "ZA", iata: "JNB", latitude: -26.1392, longitude: 28.2460, unlockTier: 3),
        Airport(id: "NRT", name: "Narita International", city: "Tokyo", country: "Japan", countryCode: "JP", iata: "NRT", latitude: 35.7720, longitude: 140.3929, unlockTier: 3),
        Airport(id: "BKK", name: "Suvarnabhumi", city: "Bangkok", country: "Thailand", countryCode: "TH", iata: "BKK", latitude: 13.6900, longitude: 100.7501, unlockTier: 3)
    ]

    static func airport(iata: String) -> Airport? {
        all.first { $0.iata == iata }
    }

    static func nearest(to location: CLLocation) -> Airport {
        all.min(by: { $0.location.distance(from: location) < $1.location.distance(from: location) }) ?? all[0]
    }

    static func unlocked(from unlockedIATAs: Set<String>) -> [Airport] {
        all.filter { unlockedIATAs.contains($0.iata) }
    }
}
