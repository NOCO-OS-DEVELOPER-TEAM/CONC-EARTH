import MapKit
import SwiftUI

struct InFlightView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var store: SessionStore
    @EnvironmentObject private var timer: FocusTimerService

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var cabinNoiseOn = true

    private var session: FocusSession? { store.activeSession }

    private var progress: Double {
        session?.progress(at: timer.now) ?? 0
    }

    private var remaining: TimeInterval {
        session?.remainingSeconds(at: timer.now) ?? 0
    }

    private var atmosphere: AtmosphereCondition {
        guard let session else { return .clear }
        return AtmosphereEngine.condition(scenario: session.scenario, progress: progress, at: timer.now)
    }

    private var phase: FlightPhase {
        session?.phase(at: timer.now) ?? .cruise
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

    var body: some View {
        ZStack {
            if coordinator.presentationMode == .window,
               let session,
               session.seat.unlocksWindowView {
                WindowSeatExperience(
                    session: session,
                    progress: progress,
                    remaining: remaining,
                    atmosphere: atmosphere
                )
            } else {
                mapExperience
            }

            VStack {
                topBar
                if coordinator.showStayFocusedHint {
                    Text("Stay with the flight.")
                        .font(CEFont.body(13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.top, 8)
                        .transition(.opacity)
                }
                Spacer()
                if coordinator.presentationMode == .map {
                    mapBottomStats
                }
            }
        }
        .onAppear {
            cabinNoiseOn = store.soundsEnabled
            updateCamera(animated: false)
        }
        .onChange(of: progress) { _, _ in updateCamera(animated: false) }
        .onChange(of: coordinator.cameraMode) { _, _ in updateCamera(animated: true) }
        .onChange(of: coordinator.presentationMode) { _, _ in updateCamera(animated: true) }
        .onChange(of: timer.now) { _, _ in
            if session?.status == .inFlight || session?.status == .landing {
                updateCamera(animated: false)
            }
        }
    }

    private var topBar: some View {
        HStack(alignment: .top) {
            VStack(spacing: 10) {
                GlassCircleButton(
                    systemName: session?.status == .paused ? "play.fill" : "pause.fill",
                    filled: session?.status == .paused
                ) {
                    coordinator.togglePause()
                }

                GlassCircleButton(systemName: cabinNoiseOn ? "speaker.wave.2" : "speaker.slash") {
                    cabinNoiseOn.toggle()
                    coordinator.audio.setCabinNoise(
                        enabled: cabinNoiseOn && session?.status != .paused,
                        soundsOn: store.soundsEnabled
                    )
                }
            }

            Spacer()

            if session?.seat.unlocksWindowView == true {
                presentationToggle
            }

            Spacer()

            VStack(spacing: 10) {
                if coordinator.presentationMode == .map {
                    GlassCircleButton(systemName: "point.topleft.down.to.point.bottomright.curvepath") {
                        coordinator.cameraMode = coordinator.cameraMode == .route ? .follow : .route
                    }
                }
                GlassCircleButton(systemName: "circle.dotted") {
                    coordinator.pulseStayFocused()
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
    }

    private var presentationToggle: some View {
        HStack(spacing: 0) {
            toggleChip("Window", selected: coordinator.presentationMode == .window) {
                if coordinator.presentationMode != .window {
                    coordinator.togglePresentation()
                }
            }
            toggleChip("Map", selected: coordinator.presentationMode == .map) {
                if coordinator.presentationMode != .map {
                    coordinator.togglePresentation()
                }
            }
        }
        .padding(3)
        .background(.ultraThinMaterial, in: Capsule())
    }

    private func toggleChip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(CEFont.body(12, weight: .semibold))
                .foregroundStyle(selected ? CEColor.ink : .white.opacity(0.75))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(selected ? Color.white : Color.clear, in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private var mapExperience: some View {
        ZStack {
            Map(position: $cameraPosition) {
                if let session {
                    let path = RouteGeometry.sampledPath(
                        from: session.route.origin.coordinate,
                        to: session.route.destination.coordinate
                    )
                    MapPolyline(coordinates: path)
                        .stroke(Color.white.opacity(0.28), lineWidth: 2)

                    let flownCount = max(2, Int(Double(path.count - 1) * progress) + 1)
                    MapPolyline(coordinates: Array(path.prefix(flownCount)))
                        .stroke(Color.white.opacity(0.85), lineWidth: 2.5)

                    Annotation("DEP", coordinate: session.route.origin.coordinate) {
                        tinyMarker()
                    }
                    Annotation("ARR", coordinate: session.route.destination.coordinate) {
                        tinyMarker()
                    }
                    Annotation("PLANE", coordinate: planeCoordinate) {
                        PlaneMarker(
                            heading: RouteGeometry.heading(
                                from: session.route.origin.coordinate,
                                to: session.route.destination.coordinate,
                                progress: progress
                            )
                        )
                    }
                }
            }
            .mapStyle(.imagery(elevation: .realistic))
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

    private var mapBottomStats: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(session?.status == .paused ? "Paused" : phase.title)
                    .font(CEFont.body(12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
                Text(TimeFormatting.clock(remaining))
                    .font(CEFont.display(32, weight: .bold))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                if let session {
                    Text("\(session.route.originIATA) → \(session.route.destinationIATA)")
                        .font(CEFont.body(12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(atmosphere.title)
                    .font(CEFont.body(12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
                Text("\(Int(progress * 100))%")
                    .font(CEFont.display(32, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
        .background(
            LinearGradient(colors: [.clear, .black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    private func tinyMarker() -> some View {
        Circle()
            .fill(CEColor.aviationYellow)
            .frame(width: 8, height: 8)
    }

    private func updateCamera(animated: Bool) {
        guard let session else { return }
        guard coordinator.presentationMode == .map else { return }
        let pose = RouteGeometry.cameraPose(
            mode: coordinator.cameraMode == .window ? .follow : coordinator.cameraMode,
            origin: session.route.origin.coordinate,
            destination: session.route.destination.coordinate,
            progress: progress,
            scenario: session.scenario
        )
        let camera = MapCamera(
            centerCoordinate: pose.center,
            distance: pose.distance,
            heading: pose.heading,
            pitch: pose.pitch
        )
        if animated {
            withAnimation(.easeInOut(duration: 0.7)) {
                cameraPosition = .camera(camera)
            }
        } else {
            cameraPosition = .camera(camera)
        }
    }
}

struct PlaneMarker: View {
    let heading: Double

    var body: some View {
        Image(systemName: "airplane")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.4), radius: 3, y: 1)
            .rotationEffect(.degrees(heading - 90))
    }
}
