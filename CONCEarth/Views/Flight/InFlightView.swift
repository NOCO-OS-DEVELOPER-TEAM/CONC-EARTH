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
    @State private var showCancelConfirm = false
    @State private var toast: String?
    @State private var lastCameraUpdate = Date.distantPast

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

    private var course: Double {
        guard let session else { return 0 }
        return RouteGeometry.heading(
            from: session.route.origin.coordinate,
            to: session.route.destination.coordinate,
            progress: progress
        )
    }

    /// Annotations stay screen-fixed. In follow mode the map faces `course`, so nose-up = 0.
    private var planeScreenHeading: Double {
        coordinator.cameraMode == .follow || coordinator.presentationMode == .window ? 0 : course
    }

    var body: some View {
        ZStack {
            if coordinator.presentationMode == .window, let session, session.seat.unlocksWindowView {
                WindowSeatExperience(
                    session: session,
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

                if let toast {
                    Text(toast)
                        .font(CEFont.body(13, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.top, 10)
                        .transition(.opacity)
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

            if showMapStyles { mapStyleSheet }
            if showCancelConfirm { cancelSheet }
        }
        .onAppear {
            cabinNoiseOn = store.soundsEnabled
            coordinator.cameraMode = .follow
            coordinator.presentationMode = .map
            updateCamera(animated: false, force: true)
            if cabinNoiseOn {
                coordinator.audio.setCabinNoise(enabled: true, soundsOn: store.soundsEnabled)
            }
        }
        .onChange(of: coordinator.cameraMode) { _, _ in updateCamera(animated: true, force: true) }
        .onChange(of: coordinator.presentationMode) { _, mode in
            if mode == .map { updateCamera(animated: true, force: true) }
        }
        .onChange(of: timer.now) { _, now in
            guard session?.status == .inFlight || session?.status == .landing else { return }
            // Throttle map camera updates to cut lag / crashes.
            if now.timeIntervalSince(lastCameraUpdate) >= 1.0 {
                updateCamera(animated: false, force: false)
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
        HStack(alignment: .top) {
            VStack(spacing: 10) {
                GlassCircleButton(
                    systemName: session?.status == .paused ? "play.fill" : "pause.fill",
                    filled: session?.status == .paused
                ) { coordinator.togglePause() }

                // Kabinenrauschen
                Button {
                    cabinNoiseOn.toggle()
                    coordinator.audio.setCabinNoise(
                        enabled: cabinNoiseOn && session?.status != .paused,
                        soundsOn: true
                    )
                    flashToast(cabinNoiseOn ? "Kabinenrauschen an" : "Kabinenrauschen aus")
                } label: {
                    labeledChrome(systemName: cabinNoiseOn ? "speaker.wave.2.fill" : "speaker.slash.fill", title: "Ton")
                }
                .buttonStyle(.plain)

                Button {
                    showCancelConfirm = true
                } label: {
                    labeledChrome(systemName: "xmark", title: "Ende")
                }
                .buttonStyle(.plain)
            }

            Spacer()

            VStack(spacing: 10) {
                Button {
                    coordinator.cameraMode = .route
                    coordinator.presentationMode = .map
                    flashToast("Routenansicht")
                } label: {
                    labeledChrome(
                        systemName: "point.topleft.down.to.point.bottomright.curvepath",
                        title: "Route",
                        filled: coordinator.cameraMode == .route && coordinator.presentationMode == .map
                    )
                }
                .buttonStyle(.plain)

                Button {
                    coordinator.cameraMode = .follow
                    coordinator.presentationMode = .map
                    flashToast("Verfolgen")
                    updateCamera(animated: true, force: true)
                } label: {
                    labeledChrome(
                        systemName: "location.north.line.fill",
                        title: "Folgen",
                        filled: coordinator.cameraMode == .follow && coordinator.presentationMode == .map
                    )
                }
                .buttonStyle(.plain)

                Button {
                    showMapStyles = true
                } label: {
                    labeledChrome(systemName: "square.3.layers.3d", title: "Karte")
                }
                .buttonStyle(.plain)

                Button {
                    if session?.seat.unlocksWindowView == true {
                        coordinator.presentationMode = .window
                        coordinator.cameraMode = .window
                        flashToast("Fensteransicht")
                    } else {
                        flashToast("Fensterplatz wählen (A/F)")
                    }
                } label: {
                    labeledChrome(
                        systemName: "window.ceiling",
                        title: "Fenster",
                        filled: coordinator.presentationMode == .window
                    )
                }
                .buttonStyle(.plain)

                Button {
                    coordinator.openLearnWhileFlying()
                } label: {
                    labeledChrome(systemName: "book.fill", title: "Lernen")
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func labeledChrome(systemName: String, title: String, filled: Bool = false) -> some View {
        VStack(spacing: 3) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(filled ? CEColor.ink : .white)
                .frame(width: 44, height: 44)
                .background {
                    if filled {
                        Circle().fill(.white)
                    } else {
                        Circle().fill(.ultraThinMaterial)
                    }
                }
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var mapLayer: some View {
        ZStack {
            Map(position: $cameraPosition, interactionModes: [.zoom, .pan]) {
                if let session {
                    let path = RouteGeometry.sampledPath(
                        from: session.route.origin.coordinate,
                        to: session.route.destination.coordinate,
                        samples: 36
                    )
                    MapPolyline(coordinates: path)
                        .stroke(Color.white.opacity(0.28), lineWidth: 2)

                    let flownCount = max(2, Int(Double(path.count - 1) * progress) + 1)
                    MapPolyline(coordinates: Array(path.prefix(flownCount)))
                        .stroke(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 3, lineCap: .round))

                    Annotation("", coordinate: session.route.origin.coordinate) {
                        AirportRunwayBadge(systemName: "airplane.departure")
                    }
                    Annotation("", coordinate: session.route.destination.coordinate) {
                        AirportRunwayBadge(systemName: "airplane.arrival")
                    }
                    Annotation("", coordinate: planeCoordinate) {
                        PlaneMarker(heading: planeScreenHeading, scale: 1.15)
                    }
                }
            }
            .mapStyle(currentMapStyle)
            .mapControls { }
            .ignoresSafeArea()
        }
    }

    private var currentMapStyle: MapStyle {
        switch mapStyleIndex {
        case 1: return .standard(elevation: .realistic)
        case 2: return .hybrid(elevation: .realistic)
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
                    styleTile("Satellit", index: 0, tint: .brown)
                    styleTile("Standard", index: 1, tint: .green)
                    styleTile("Hybrid", index: 2, tint: .blue)
                }
            }
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(22)
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.top, 56)
        }
    }

    private var cancelSheet: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Flug abbrechen?")
                    .font(CEFont.display(22, weight: .bold))
                    .foregroundStyle(.white)
                Text("Der Fokusflug wird beendet und nicht als abgeschlossen gespeichert.")
                    .font(CEFont.body(14))
                    .foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                PrimaryPillButton(title: "Flug abbrechen") {
                    showCancelConfirm = false
                    coordinator.cancelFlight()
                }
                Button("Weiterfliegen") {
                    showCancelConfirm = false
                }
                .font(CEFont.body(15, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(28)
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
                    .frame(height: 72)
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

    private func flashToast(_ text: String) {
        withAnimation(.easeOut(duration: 0.2)) { toast = text }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeOut(duration: 0.25)) {
                if toast == text { toast = nil }
            }
        }
    }

    private func updateCamera(animated: Bool, force: Bool) {
        guard let session else { return }
        guard coordinator.presentationMode == .map else { return }
        let now = Date()
        if !force, now.timeIntervalSince(lastCameraUpdate) < 0.9 { return }
        lastCameraUpdate = now

        let mode: FlightCameraMode = coordinator.cameraMode == .window ? .follow : coordinator.cameraMode
        let pose = RouteGeometry.cameraPose(
            mode: mode,
            origin: session.route.origin.coordinate,
            destination: session.route.destination.coordinate,
            progress: progress,
            scenario: session.scenario
        )

        // Keep the aircraft visible and centered in follow mode (closer = easier to spot).
        let center = mode == .follow ? planeCoordinate : pose.center
        let distance: CLLocationDistance = mode == .follow ? 7_500 : max(pose.distance, 80_000)
        let pitch: CGFloat = mode == .follow ? 48 : 35
        let heading = mode == .follow ? course : 0

        let camera = MapCamera(
            centerCoordinate: center,
            distance: distance,
            heading: heading,
            pitch: pitch
        )
        if animated {
            withAnimation(.easeInOut(duration: 0.6)) {
                cameraPosition = .camera(camera)
            }
        } else {
            cameraPosition = .camera(camera)
        }
    }
}
