import MapKit
import SwiftUI

/// Signature immersive window-seat view — calm, cinematic, minimal chrome.
struct WindowSeatExperience: View {
    let session: FocusSession
    let progress: Double
    let remaining: TimeInterval
    let atmosphere: AtmosphereCondition

    @State private var cloudDrift: CGFloat = 0
    @State private var cameraPosition: MapCameraPosition = .automatic

    private var planeCoordinate: CLLocationCoordinate2D {
        RouteGeometry.point(
            from: session.route.origin.coordinate,
            to: session.route.destination.coordinate,
            progress: progress
        )
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                mapThroughWindow
                atmosphereWash
                cloudLayer(in: geo.size)
                windowFrame
                bottomChrome
            }
        }
        .onAppear {
            updateCamera(animated: false)
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: true)) {
                cloudDrift = 28
            }
        }
        .onChange(of: progress) { _, _ in
            updateCamera(animated: false)
        }
    }

    private var mapThroughWindow: some View {
        Map(position: $cameraPosition) {
            MapPolyline(
                coordinates: RouteGeometry.sampledPath(
                    from: session.route.origin.coordinate,
                    to: session.route.destination.coordinate
                )
            )
            .stroke(Color.white.opacity(0.12), lineWidth: 1)
        }
        .mapStyle(.imagery(elevation: .realistic))
        .mapControls { }
        .allowsHitTesting(false)
    }

    private var atmosphereWash: some View {
        LinearGradient(
            colors: AtmosphereEngine.washColors(for: atmosphere),
            startPoint: .top,
            endPoint: .bottom
        )
        .allowsHitTesting(false)
    }

    private func cloudLayer(in size: CGSize) -> some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                Capsule()
                    .fill(.white.opacity(atmosphere == .night ? 0.04 : 0.07 + Double(i) * 0.015))
                    .frame(width: size.width * (0.28 + CGFloat(i) * 0.08), height: 14 + CGFloat(i) * 3)
                    .offset(
                        x: cloudDrift + CGFloat(i * 18 - 40),
                        y: size.height * (0.18 + CGFloat(i) * 0.09)
                    )
                    .blur(radius: 3)
            }

            if atmosphere == .rain {
                ForEach(0..<12, id: \.self) { i in
                    Capsule()
                        .fill(.white.opacity(0.12))
                        .frame(width: 1.2, height: 10)
                        .offset(
                            x: CGFloat((i * 37) % Int(max(size.width, 1))) - size.width / 2,
                            y: CGFloat((i * 53) % 120) - 40
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var windowFrame: some View {
        ZStack {
            // Soft vignette outside the pane
            Rectangle()
                .fill(
                    RadialGradient(
                        colors: [.clear, .black.opacity(0.55)],
                        center: .center,
                        startRadius: 120,
                        endRadius: 420
                    )
                )

            RoundedRectangle(cornerRadius: 46, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.28), .white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 10
                )
                .padding(26)
                .shadow(color: .black.opacity(0.35), radius: 18)

            // Shade latch
            Capsule()
                .fill(.white.opacity(0.16))
                .frame(width: 72, height: 6)
                .padding(.top, 44)
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .allowsHitTesting(false)
    }

    private var bottomChrome: some View {
        VStack {
            Spacer()
            VStack(spacing: 8) {
                Text("\(session.route.originIATA) → \(session.route.destinationIATA)")
                    .font(CEFont.body(14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))

                Text("\(TimeFormatting.clock(remaining)) remaining")
                    .font(CEFont.mono(13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))

                Capsule()
                    .fill(.white.opacity(0.12))
                    .frame(width: 120, height: 3)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.7))
                            .frame(width: 120 * progress, height: 3)
                    }

                Text("Cruising · \(atmosphere.title)")
                    .font(CEFont.body(11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.35))
                    .padding(.top, 2)
            }
            .padding(.bottom, 28)
        }
        .allowsHitTesting(false)
    }

    private func updateCamera(animated: Bool) {
        let pose = RouteGeometry.cameraPose(
            mode: .window,
            origin: session.route.origin.coordinate,
            destination: session.route.destination.coordinate,
            progress: progress,
            scenario: session.scenario
        )
        let camera = MapCamera(
            centerCoordinate: pose.center,
            distance: pose.distance,
            heading: pose.heading,
            pitch: min(pose.pitch + 8, 75)
        )
        if animated {
            withAnimation(.easeInOut(duration: 1.0)) {
                cameraPosition = .camera(camera)
            }
        } else {
            cameraPosition = .camera(camera)
        }
    }
}
