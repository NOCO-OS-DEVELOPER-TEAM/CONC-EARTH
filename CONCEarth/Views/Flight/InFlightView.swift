import MapKit
import SwiftUI

struct InFlightView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var store: SessionStore
    @EnvironmentObject private var timer: FocusTimerService

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var cabinNoiseOn = true
    @State private var showMapStyles = false
    @State private var mapStyleIndex = 0
    @State private var showLabels = true

    private var session: FocusSession? { store.activeSession }

    private var progress: Double {
        session?.progress(at: timer.now) ?? 0
    }

    private var remaining: TimeInterval {
        session?.remainingSeconds(at: timer.now) ?? 0
    }

    private var flownKilometers: Double {
        (session?.route.distanceKilometers ?? 0) * progress
    }

    private var atmosphere: AtmosphereCondition {
        guard let session else { return .clear }
        return AtmosphereEngine.condition(scenario: session.scenario, progress: progress, at: timer.now)
    }

    private var planeCoordinate: CLLocationCoordinate2D {
        guard let session else {
            return CLLocationCoordinate2D(latitude: 51, longitude: 10)
        }
        return RouteGeometry.point(
            from: session.route.origin.coordinate,
            to: session.route.destination.coordinate,
            progress: progress
        )
    }

    private var heading: Double {
        guard let session else { return 0 }
        return RouteGeometry.heading(
            from: session.route.origin.coordinate,
            to: session.route.destination.coordinate,
            progress: progress
        )
    }

    var body: some View {
        ZStack {
            if coordinator.presentationMode == .window, session?.seat.unlocksWindowView == true {
                WindowSeatExperience(
                    session: session!,
                    progress: progress,
                    remaining: remaining,
                    atmosphere: atmosphere,
                    flownKilometers: flownKilometers
                )
            } else {
                mapLayer
            }

            VStack(spacing: 0) {
                chrome
                    .padding(.horizontal, 14)
                    .padding(.top, 8)

                if coordinator.showStayFocusedHint {
                    Text("Bleib an Bord.")
                        .font(CEFont.body(13, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.top, 10)
                }

                Spacer()

                if coordinator.presentationMode == .map {
                    FlightBottomMetrics(
                        leftLabel: session?.status == .paused ? "Pausiert" : "Flugdauer",
                        leftValue: TimeFormatting.clock(remaining),
                        rightLabel: "Flugstrecke",
                        rightValue: distanceLabel
                    )
                }
            }

            if showMapStyles {
                mapStyleSheet
            }
        }
        .onAppear {
            cabinNoiseOn = store.soundsEnabled
            // Default follow mode feels closest to Focus Flight.
            if coordinator.cameraMode != .follow && coordinator.presentationMode == .map {
                coordinator.cameraMode = .follow
            }
            updateCamera(animated: false)
        }
        .onChange(of: progress) { _, _ in updateCamera(animated: false) }
        .onChange(of: coordinator.cameraMode) { _, _ in updateCamera(animated: true) }
        .onChange(of: coordinator.presentationMode) { _, mode in
            if mode == .map { updateCamera(animated: true) }
        }
        .onChange(of: timer.now) { _, _ in
            if session?.status == .inFlight || session?.status == .landing {
                updateCamera(animated: false)
            }
        }
    }

    private var distanceLabel: String {
        if flownKilometers < 1 {
            return String(format: "%.0f m", flownKilometers * 1000)
        }
        return String(format: "%.0f km", flownKilometers)
    }

    private var chrome: some View {
        FlightGlassStack(
            left: [
                FlightChromeButton(
                    systemName: session?.status == .paused ? "play.fill" : "pause.fill",
                    emphasized: session?.status == .paused
                ) { coordinator.togglePause() },
                FlightChromeButton(systemName: cabinNoiseOn ? "music.note" : "speaker.slash") {
                    cabinNoiseOn.toggle()
                    coordinator.audio.setCabinNoise(
                        enabled: cabinNoiseOn && session?.status != .paused,
                        soundsOn: store.soundsEnabled
                    )
                },
                FlightChromeButton(systemName: "rectangle.on.rectangle") {
                    coordinator.openLearnWhileFlying()
                }
            ],
            right: [
                FlightChromeButton(
                    systemName: "point.topleft.down.to.point.bottomright.curvepath",
                    emphasized: coordinator.cameraMode == .route,
                    wide: true
                ) {
                    coordinator.cameraMode = .route
                    coordinator.presentationMode = .map
                },
                FlightChromeButton(
                    systemName: "location.north.line.fill",
                    emphasized: coordinator.cameraMode == .follow && coordinator.presentationMode == .map
                ) {
                    coordinator.cameraMode = .follow
                    coordinator.presentationMode = .map
                },
                FlightChromeButton(systemName: "square.3.layers.3d") {
                    showMapStyles = true
                },
                FlightChromeButton(
                    systemName: session?.seat.unlocksWindowView == true ? "window.ceiling" : "iphone",
                    emphasized: coordinator.presentationMode == .window
                ) {
                    if session?.seat.unlocksWindowView == true {
                        coordinator.presentationMode = .window
                        coordinator.cameraMode = .window
                    } else {
                        coordinator.pulseStayFocused()
                    }
                }
            ]
        )
    }

    private var mapLayer: some View {
        ZStack {
            Map(position: $cameraPosition) {
                if let session {
                    let path = RouteGeometry.sampledPath(
                        from: session.route.origin.coordinate,
                        to: session.route.destination.coordinate,
                        samples: 80
                    )
                    MapPolyline(coordinates: path)
                        .stroke(Color.white.opacity(0.28), lineWidth: 2)

                    let flownCount = max(2, Int(Double(path.count - 1) * progress) + 1)
                    MapPolyline(coordinates: Array(path.prefix(flownCount)))
                        .stroke(
                            .linearGradient(
                                colors: [.white.opacity(0.15), .white.opacity(0.95)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )

                    Annotation("", coordinate: session.route.origin.coordinate) {
                        AirportRunwayBadge(systemName: "airplane.departure")
                    }
                    Annotation("", coordinate: session.route.destination.coordinate) {
                        AirportRunwayBadge(systemName: "airplane.arrival")
                    }
                    Annotation("", coordinate: planeCoordinate) {
                        // In follow mode the map already faces the route heading,
                        // so keep the jet nose pointing "up" the screen.
                        PlaneMarker(heading: coordinator.cameraMode == .follow ? 0 : heading)
                    }
                }
            }
            .mapStyle(currentMapStyle)
            .mapControls { }
            .ignoresSafeArea()

            LinearGradient(
                colors: AtmosphereEngine.washColors(for: atmosphere),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }

    private var currentMapStyle: MapStyle {
        switch mapStyleIndex {
        case 1: return .standard(elevation: .realistic)
        case 2: return .hybrid(elevation: .realistic)
        case 3: return .imagery(elevation: .realistic)
        default: return .imagery(elevation: .realistic)
        }
    }

    private var mapStyleSheet: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
                .onTapGesture { showMapStyles = false }

            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Kartenstil wählen")
                        .font(CEFont.body(18, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    GlassCircleButton(systemName: "xmark") { showMapStyles = false }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    styleTile("Monochrom", index: 1, tint: .gray)
                    styleTile("Terra", index: 3, tint: .blue)
                    styleTile("Standard", index: 1, tint: .green)
                    styleTile("Satellit", index: 0, tint: .brown)
                }

                HStack {
                    Text("Labels")
                        .foregroundStyle(.white)
                    Spacer()
                    Button(showLabels ? "• EIN" : "AUS") {
                        showLabels.toggle()
                    }
                    .foregroundStyle(showLabels ? CEColor.horizonTeal : .white.opacity(0.5))
                    .font(CEFont.body(14, weight: .semibold))
                }
            }
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(22)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 56)
        }
    }

    private func styleTile(_ title: String, index: Int, tint: Color) -> some View {
        Button {
            mapStyleIndex = index
            showMapStyles = false
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(tint.opacity(0.35))
                    .frame(height: 78)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(mapStyleIndex == index ? Color.white : Color.clear, lineWidth: 2.5)
                    )
                Text(title)
                    .font(CEFont.body(13, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }

    private func updateCamera(animated: Bool) {
        guard let session else { return }
        guard coordinator.presentationMode == .map else { return }

        let mode: FlightCameraMode = coordinator.cameraMode == .window ? .follow : coordinator.cameraMode
        let pose = RouteGeometry.cameraPose(
            mode: mode,
            origin: session.route.origin.coordinate,
            destination: session.route.destination.coordinate,
            progress: progress,
            scenario: session.scenario
        )
        // Follow mode: closer, more cinematic like Focus Flight takeoff/cruise shots.
        let distance = mode == .follow ? min(pose.distance, 14_000) : pose.distance
        let pitch = mode == .follow ? max(pose.pitch, 58) : pose.pitch
        let camera = MapCamera(
            centerCoordinate: pose.center,
            distance: distance,
            heading: pose.heading,
            pitch: pitch
        )
        if animated {
            withAnimation(.easeInOut(duration: 0.75)) {
                cameraPosition = .camera(camera)
            }
        } else {
            cameraPosition = .camera(camera)
        }
    }
}
