import CoreLocation
import Foundation
import MapKit

enum RouteGeometry {
    static func distanceKilometers(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let a = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let b = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return a.distance(from: b) / 1000.0
    }

    /// Great-circle interpolation with a mild lateral curve for a flight-path feel.
    static func point(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, progress: Double) -> CLLocationCoordinate2D {
        let t = min(1, max(0, progress))
        let lat1 = from.latitude * .pi / 180
        let lon1 = from.longitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let lon2 = to.longitude * .pi / 180

        let d = 2 * asin(sqrt(pow(sin((lat2 - lat1) / 2), 2) + cos(lat1) * cos(lat2) * pow(sin((lon2 - lon1) / 2), 2)))
        guard d > 1e-8 else { return from }

        let a = sin((1 - t) * d) / sin(d)
        let b = sin(t * d) / sin(d)
        let x = a * cos(lat1) * cos(lon1) + b * cos(lat2) * cos(lon2)
        let y = a * cos(lat1) * sin(lon1) + b * cos(lat2) * sin(lon2)
        let z = a * sin(lat1) + b * sin(lat2)

        var lat = atan2(z, sqrt(x * x + y * y))
        var lon = atan2(y, x)

        // Gentle arc offset perpendicular to the route.
        let bearing = initialBearing(from: from, to: to) * .pi / 180
        let offset = sin(t * .pi) * 0.15 * (.pi / 180)
        lat += cos(bearing + .pi / 2) * offset
        lon += sin(bearing + .pi / 2) * offset / max(cos(lat), 0.2)

        return CLLocationCoordinate2D(latitude: lat * 180 / .pi, longitude: lon * 180 / .pi)
    }

    static func sampledPath(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, samples: Int = 64) -> [CLLocationCoordinate2D] {
        (0...samples).map { index in
            point(from: from, to: to, progress: Double(index) / Double(samples))
        }
    }

    static func initialBearing(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let dLon = (to.longitude - from.longitude) * .pi / 180
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x) * 180 / .pi
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }

    static func heading(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, progress: Double) -> Double {
        let p0 = point(from: from, to: to, progress: max(0, progress - 0.002))
        let p1 = point(from: from, to: to, progress: min(1, progress + 0.002))
        return initialBearing(from: p0, to: p1)
    }

    static func mapCamera(
        mode: FlightCameraMode,
        origin: CLLocationCoordinate2D,
        destination: CLLocationCoordinate2D,
        progress: Double,
        scenario: FlightScenario
    ) -> MapCamera {
        let plane = point(from: origin, to: destination, progress: progress)
        let heading = heading(from: origin, to: destination, progress: progress)

        switch mode {
        case .route:
            let mid = point(from: origin, to: destination, progress: 0.5)
            let distance = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
                .distance(from: CLLocation(latitude: destination.latitude, longitude: destination.longitude))
            let altitude = max(80_000, min(1_800_000, distance * 1.35))
            return MapCamera(centerCoordinate: mid, distance: altitude, heading: 0, pitch: 35)
        case .follow:
            let altitude: CLLocationDistance = scenario == .longHaul ? 18_000 : 12_000
            return MapCamera(centerCoordinate: plane, distance: altitude, heading: heading, pitch: 55)
        case .window:
            let altitude: CLLocationDistance = 8_500
            return MapCamera(centerCoordinate: plane, distance: altitude, heading: heading + 25, pitch: 70)
        }
    }
}

enum FlightCameraMode: String, CaseIterable, Identifiable {
    case route
    case follow
    case window

    var id: String { rawValue }

    var title: String {
        switch self {
        case .route: return "Route"
        case .follow: return "Follow"
        case .window: return "Window"
        }
    }

    var systemImage: String {
        switch self {
        case .route: return "point.topleft.down.to.point.bottomright.curvepath"
        case .follow: return "location.north.line.fill"
        case .window: return "rectangle.inset.filled"
        }
    }
}
