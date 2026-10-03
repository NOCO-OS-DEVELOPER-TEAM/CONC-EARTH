import MapKit
import SwiftUI

struct FlightSelectionView: View {
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var cameraPosition: MapCameraPosition = .automatic

    private var routes: [FlightRoute] {
        RouteCatalog.routes(reachableWithinMinutes: coordinator.focusMinutes, from: coordinator.homeAirport.iata)
    }

    private let focusOptions = [25, 30, 45, 60, 90, 120]

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                if let origin = AirportCatalog.airport(iata: coordinator.homeAirport.iata) {
                    Annotation(origin.iata, coordinate: origin.coordinate) {
                        airportBadge(code: origin.iata, selected: false)
                    }
                }

                ForEach(routes) { route in
                    let dest = route.destination
                    Annotation(dest.iata, coordinate: dest.coordinate) {
                        airportBadge(code: dest.iata, selected: coordinator.selectedRoute?.id == route.id)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                    coordinator.selectedRoute = route
                                }
                            }
                    }

                    MapPolyline(coordinates: RouteGeometry.sampledPath(from: route.origin.coordinate, to: dest.coordinate))
                        .stroke(
                            coordinator.selectedRoute?.id == route.id ? Color.white : Color.white.opacity(0.25),
                            lineWidth: coordinator.selectedRoute?.id == route.id ? 3 : 1.5
                        )
                }
            }
            .mapStyle(.imagery(elevation: .realistic))
            .ignoresSafeArea()
            .onAppear { updateCamera() }
            .onChange(of: coordinator.selectedRoute) { _, _ in updateCamera() }

            VStack {
                topBar
                Spacer()
                bottomSheet
            }
        }
    }

    private var topBar: some View {
        HStack {
            GlassCircleButton(systemName: "chevron.left") {
                coordinator.backFromSelection()
            }
            Spacer()
            HStack(spacing: 10) {
                GlassCircleButton(systemName: "shuffle") {
                    if let random = routes.randomElement() {
                        coordinator.selectedRoute = random
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var bottomSheet: some View {
        VStack(spacing: 14) {
            scenarioRow
            durationDial
            routeCards
            PrimaryPillButton(title: "Book Flight", isEnabled: coordinator.selectedRoute != nil) {
                coordinator.confirmFlight()
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(Color.black.opacity(0.28))
                )
        )
        .padding(.horizontal, 10)
        .padding(.bottom, 8)
    }

    private var scenarioRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(FlightScenario.allCases) { scenario in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            coordinator.selectedScenario = scenario
                            coordinator.focusMinutes = scenario.recommendedMinutes
                        }
                    } label: {
                        Text(scenario.title)
                            .font(CEFont.body(13, weight: .semibold))
                            .foregroundStyle(coordinator.selectedScenario == scenario ? CEColor.ink : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(coordinator.selectedScenario == scenario ? Color.white : Color.white.opacity(0.12))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var durationDial: some View {
        VStack(spacing: 8) {
            Text("Focus duration")
                .font(CEFont.body(12, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
            HStack(spacing: 8) {
                ForEach(focusOptions, id: \.self) { minutes in
                    Button {
                        coordinator.focusMinutes = minutes
                    } label: {
                        Text(TimeFormatting.minutesLabel(minutes))
                            .font(CEFont.mono(13, weight: .semibold))
                            .foregroundStyle(coordinator.focusMinutes == minutes ? CEColor.ink : .white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                Capsule().fill(coordinator.focusMinutes == minutes ? CEColor.aviationYellow : Color.white.opacity(0.1))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var routeCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(routes.prefix(6)) { route in
                    Button {
                        coordinator.selectedRoute = route
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Text(route.destinationIATA)
                                    .font(CEFont.body(12, weight: .bold))
                                Image(systemName: "airplane")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .foregroundStyle(CEColor.ink)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(CEColor.aviationYellow, in: RoundedRectangle(cornerRadius: 6))

                            Text(route.destination.city)
                                .font(CEFont.body(16, weight: .bold))
                                .foregroundStyle(coordinator.selectedRoute?.id == route.id ? CEColor.ink : .white)
                            Text(TimeFormatting.minutesLabel(coordinator.focusMinutes))
                                .font(CEFont.body(13))
                                .foregroundStyle(coordinator.selectedRoute?.id == route.id ? CEColor.ink.opacity(0.6) : .white.opacity(0.55))
                            Text(String(format: "%.0f km · %@", route.distanceKilometers, route.flightNumber))
                                .font(CEFont.body(11))
                                .foregroundStyle(coordinator.selectedRoute?.id == route.id ? CEColor.ink.opacity(0.55) : .white.opacity(0.45))
                        }
                        .padding(14)
                        .frame(width: 150, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(coordinator.selectedRoute?.id == route.id ? Color.white : Color.black.opacity(0.45))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func airportBadge(code: String, selected: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "airplane")
                .font(.system(size: 9, weight: .bold))
            Text(code)
                .font(CEFont.body(11, weight: .bold))
        }
        .foregroundStyle(selected ? CEColor.ink : .white)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(selected ? CEColor.aviationYellow : Color.black.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(CEColor.aviationYellow, lineWidth: selected ? 0 : 1)
                )
        )
    }

    private func updateCamera() {
        let origin = coordinator.homeAirport.coordinate
        if let route = coordinator.selectedRoute {
            let mid = RouteGeometry.point(from: origin, to: route.destination.coordinate, progress: 0.5)
            let distance = CLLocation(latitude: origin.latitude, longitude: origin.longitude)
                .distance(from: CLLocation(latitude: route.destination.latitude, longitude: route.destination.longitude))
            withAnimation(.easeInOut(duration: 0.8)) {
                cameraPosition = .camera(
                    MapCamera(centerCoordinate: mid, distance: max(120_000, distance * 1.6), heading: 0, pitch: 40)
                )
            }
        } else {
            withAnimation(.easeInOut(duration: 0.8)) {
                cameraPosition = .camera(
                    MapCamera(centerCoordinate: origin, distance: 700_000, heading: 0, pitch: 45)
                )
            }
        }
    }
}
