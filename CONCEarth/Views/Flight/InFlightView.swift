import MapKit
import SwiftUI

struct InFlightView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var store: SessionStore
    @EnvironmentObject private var timer: FocusTimerService

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var mapStyleIndex = 0
    @State private var showMapStyles = false
    @State private var cabinNoiseOn = true
    @State private var trailProgress: Double = 0

    private var session: FocusSession? { store.activeSession }

    private var progress: Double {
        session?.progress(at: timer.now) ?? 0
    }

    private var remaining: TimeInterval {
        session?.remainingSeconds(at: timer.now) ?? 0
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

    private var flownKilometers: Double {
        (session?.route.distanceKilometers ?? 0) * progress
    }

    var body: some View {
        ZStack {
            mapLayer
            scenarioWash.allowsHitTesting(false)

            if coordinator.cameraMode == .window, session?.seat.unlocksWindowView == true {
                WindowViewOverlay(scenario: session?.scenario ?? .calm)
                    .allowsHitTesting(false)
            }

            VStack {
                HStack(alignment: .top) {
                    leftControls
                    Spacer()
                    rightControls
                }
                .padding(.horizontal, 14)
                .padding(.top, 8)

                if coordinator.showStayFocusedHint {
                    Text("Stay focused — your flight continues with you.")
                        .font(CEFont.body(13, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(.top, 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer()
                bottomStats
            }

            if showMapStyles {
                mapStylePicker
            }
        }
        .onAppear {
            cabinNoiseOn = store.soundsEnabled
            updateCamera(animated: false)
        }
        .onChange(of: progress) { _, newValue in
            trailProgress = newValue
            updateCamera(animated: true)
        }
        .onChange(of: coordinator.cameraMode) { _, _ in
            updateCamera(animated: true)
        }
        .onChange(of: timer.now) { _, _ in
            if session?.status == .inFlight {
                updateCamera(animated: false)
            }
        }
    }

    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            if let session {
                let path = RouteGeometry.sampledPath(
                    from: session.route.origin.coordinate,
                    to: session.route.destination.coordinate
                )
                MapPolyline(coordinates: path)
                    .stroke(Color.white.opacity(0.35), lineWidth: 2)

                let flownCount = max(2, Int(Double(path.count - 1) * progress) + 1)
                MapPolyline(coordinates: Array(path.prefix(flownCount)))
                    .stroke(Color.white.opacity(0.85), lineWidth: 3)

                Annotation("DEP", coordinate: session.route.origin.coordinate) {
                    marker(systemName: "airplane.departure")
                }
                Annotation("ARR", coordinate: session.route.destination.coordinate) {
                    marker(systemName: "airplane.arrival")
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
        .mapStyle(currentMapStyle)
        .mapControls { }
        .ignoresSafeArea()
    }

    private var currentMapStyle: MapStyle {
        switch mapStyleIndex {
        case 1: return .standard(elevation: .realistic)
        case 2: return .hybrid(elevation: .realistic)
        default: return .imagery(elevation: .realistic)
        }
    }

    private var scenarioWash: some View {
        Group {
            switch session?.scenario {
            case .night:
                Color.black.opacity(0.28)
            case .sunset:
                LinearGradient(colors: [CEColor.duskOrange.opacity(0.18), .clear], startPoint: .top, endPoint: .center)
            case .storm:
                Color.black.opacity(0.22)
            case .morning:
                Color.orange.opacity(0.08)
            default:
                Color.clear
            }
        }
        .ignoresSafeArea()
    }

    private var leftControls: some View {
        VStack(spacing: 10) {
            GlassCircleButton(
                systemName: session?.status == .paused ? "play.fill" : "pause.fill",
                filled: session?.status == .paused
            ) {
                coordinator.togglePause()
            }

            GlassCircleButton(systemName: cabinNoiseOn ? "music.note" : "speaker.slash") {
                cabinNoiseOn.toggle()
                coordinator.audio.setCabinNoise(enabled: cabinNoiseOn && session?.status == .inFlight, soundsOn: store.soundsEnabled)
            }

            GlassCircleButton(systemName: "camera.metering.center.weighted") {
                cycleCameraMode()
            }
        }
    }

    private var rightControls: some View {
        VStack(spacing: 10) {
            modeCapsule
            GlassCircleButton(systemName: "square.3.layers.3d") {
                showMapStyles = true
            }
            GlassCircleButton(systemName: "iphone") {
                coordinator.pulseStayFocused()
            }
        }
    }

    private var modeCapsule: some View {
        VStack(spacing: 0) {
            ForEach(availableModes) { mode in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        coordinator.cameraMode = mode
                    }
                } label: {
                    Image(systemName: mode.systemImage)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(coordinator.cameraMode == mode ? CEColor.ink : .white)
                        .frame(width: 44, height: 40)
                        .background(coordinator.cameraMode == mode ? Color.white : Color.clear)
                }
                .buttonStyle(.plain)
            }
        }
        .background(.ultraThinMaterial, in: Capsule())
    }

    private var availableModes: [FlightCameraMode] {
        if session?.seat.unlocksWindowView == true {
            return [.route, .follow, .window]
        }
        return [.route, .follow]
    }

    private var bottomStats: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                Text(session?.status == .paused ? "Paused" : "Flight time")
                    .font(CEFont.body(12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
                Text(TimeFormatting.clock(remaining))
                    .font(CEFont.display(34, weight: .bold))
                    .foregroundStyle(.white)
                    .monospacedDigit()
                if let session {
                    Text("\(session.route.originIATA) → \(session.route.destinationIATA) · \(Int(progress * 100))%")
                        .font(CEFont.body(12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Distance")
                    .font(CEFont.body(12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
                Text(String(format: "%.0f km", flownKilometers))
                    .font(CEFont.display(34, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
        .background(
            LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    private var mapStylePicker: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
                .onTapGesture { showMapStyles = false }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Choose map style")
                        .font(CEFont.body(18, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    GlassCircleButton(systemName: "xmark") { showMapStyles = false }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    styleTile(title: "Satellite", index: 0)
                    styleTile(title: "Standard", index: 1)
                    styleTile(title: "Hybrid", index: 2)
                    styleTile(title: "Terra", index: 0)
                }
            }
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(24)
        }
    }

    private func styleTile(title: String, index: Int) -> some View {
        Button {
            mapStyleIndex = index
            showMapStyles = false
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(index == 0 ? Color.green.opacity(0.35) : Color.blue.opacity(0.35))
                    .frame(height: 72)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(mapStyleIndex == index ? Color.white : Color.clear, lineWidth: 2)
                    )
                Text(title)
                    .font(CEFont.body(13, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
    }

    private func marker(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(CEColor.ink)
            .padding(6)
            .background(CEColor.aviationYellow, in: RoundedRectangle(cornerRadius: 6))
    }

    private func cycleCameraMode() {
        let modes = availableModes
        guard let idx = modes.firstIndex(of: coordinator.cameraMode) else { return }
        coordinator.cameraMode = modes[(idx + 1) % modes.count]
    }

    private func updateCamera(animated: Bool) {
        guard let session else { return }
        let pose = RouteGeometry.cameraPose(
            mode: coordinator.cameraMode,
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
            withAnimation(.easeInOut(duration: 0.8)) {
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
        ZStack {
            // Soft contrail suggestion behind the plane.
            Capsule()
                .fill(.white.opacity(0.35))
                .frame(width: 4, height: 46)
                .offset(y: 28)
                .blur(radius: 1.2)

            Image(systemName: "airplane")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.45), radius: 4, y: 2)
                .rotationEffect(.degrees(heading - 90))
        }
    }
}

struct WindowViewOverlay: View {
    let scenario: FlightScenario

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Window frame
                RoundedRectangle(cornerRadius: 48, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 10)
                    .padding(28)
                    .shadow(color: .black.opacity(0.4), radius: 20)

                VStack {
                    Capsule()
                        .fill(.white.opacity(0.18))
                        .frame(width: 90, height: 8)
                        .padding(.top, 46)
                    Spacer()
                }

                // Atmospheric tint inside the window.
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .fill(windowTint.opacity(0.22))
                    .padding(38)
                    .blendMode(.plusLighter)
                    .allowsHitTesting(false)

                // Soft cloud streaks
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(.white.opacity(0.08 + Double(i) * 0.03))
                        .frame(width: geo.size.width * (0.35 + Double(i) * 0.1), height: 18)
                        .offset(x: CGFloat(i * 20 - 30), y: CGFloat(80 + i * 50))
                        .blur(radius: 2)
                }
            }
        }
        .ignoresSafeArea()
    }

    private var windowTint: Color {
        switch scenario {
        case .night: return CEColor.nightBlue
        case .sunset: return CEColor.duskOrange
        case .morning: return Color.orange
        case .storm: return CEColor.stormSlate
        case .longHaul: return CEColor.horizonTeal
        case .calm: return .white
        }
    }
}
