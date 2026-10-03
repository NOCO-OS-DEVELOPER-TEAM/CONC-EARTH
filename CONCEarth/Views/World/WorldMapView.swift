import MapKit
import SwiftUI

struct WorldMapView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var store: SessionStore
    @EnvironmentObject private var journey: JourneyStore

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 30, longitude: 20),
            span: MKCoordinateSpan(latitudeDelta: 80, longitudeDelta: 120)
        )
    )

    private var snapshot: JourneySnapshot {
        journey.snapshot(from: store)
    }

    private var activeRoute: FlightRoute? {
        store.activeSession?.route
    }

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                ForEach(journey.completedRoutes(from: store)) { route in
                    MapPolyline(
                        coordinates: RouteGeometry.sampledPath(
                            from: route.origin.coordinate,
                            to: route.destination.coordinate,
                            samples: 40
                        )
                    )
                    .stroke(Color.white.opacity(0.22), lineWidth: 1.5)
                }

                if let active = activeRoute {
                    MapPolyline(
                        coordinates: RouteGeometry.sampledPath(
                            from: active.origin.coordinate,
                            to: active.destination.coordinate
                        )
                    )
                    .stroke(CEColor.horizonTeal.opacity(0.9), lineWidth: 3)

                    Annotation(active.originIATA, coordinate: active.origin.coordinate) {
                        routeDot(active: true)
                    }
                    Annotation(active.destinationIATA, coordinate: active.destination.coordinate) {
                        routeDot(active: true)
                    }
                }

                ForEach(journey.unlockedAirports) { airport in
                    Annotation(airport.iata, coordinate: airport.coordinate) {
                        Text(airport.iata)
                            .font(CEFont.mono(9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.75))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 3)
                            .background(Color.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
            .mapStyle(.imagery(elevation: .realistic))
            .ignoresSafeArea()

            VStack {
                header
                Spacer()
                footer
            }
        }
    }

    private var header: some View {
        HStack {
            GlassCircleButton(systemName: "chevron.left") {
                coordinator.goHome()
            }
            Spacer()
            VStack(spacing: 2) {
                Text("Your World")
                    .font(CEFont.body(16, weight: .semibold))
                    .foregroundStyle(.white)
                if let active = activeRoute {
                    Text("\(active.originIATA) → \(active.destinationIATA)")
                        .font(CEFont.body(12))
                        .foregroundStyle(CEColor.horizonTeal)
                }
            }
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Already explored")
                .font(CEFont.body(12, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
            HStack {
                stat("\(snapshot.destinations)", "destinations")
                Spacer()
                stat(String(format: "%.0f km", snapshot.kilometers), "flown")
                Spacer()
                stat("\(snapshot.flights)", "flights")
            }
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .padding(.horizontal, 14)
        .padding(.bottom, 14)
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(CEFont.body(18, weight: .bold))
                .foregroundStyle(.white)
            Text(label)
                .font(CEFont.body(11))
                .foregroundStyle(.white.opacity(0.45))
        }
    }

    private func routeDot(active: Bool) -> some View {
        Circle()
            .fill(active ? CEColor.horizonTeal : .white.opacity(0.7))
            .frame(width: 8, height: 8)
    }
}
