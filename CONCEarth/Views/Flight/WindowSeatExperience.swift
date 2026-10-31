import MapKit
import SwiftUI

/// Cinematic window-seat view: MapKit landscape through a real aircraft window frame.
struct WindowSeatExperience: View {
    let session: FocusSession
    let progress: Double
    let remaining: TimeInterval
    let atmosphere: AtmosphereCondition
    let flownKilometers: Double

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var cloudPhase: CGFloat = 0
    @State private var breathe: CGFloat = 0

    private var heading: Double {
        RouteGeometry.heading(
            from: session.route.origin.coordinate,
            to: session.route.destination.coordinate,
            progress: progress
        )
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Cabin wall
                LinearGradient(
                    colors: [Color(white: 0.12), Color(white: 0.07), Color(white: 0.04)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                windowPane(in: geo.size)
                atmosphereWash
                driftingAtmosphere(in: geo.size)
                plasticWindowFrame(in: geo.size)
                bottomReadout
            }
        }
        .onAppear {
            updateCamera()
            withAnimation(.linear(duration: 28).repeatForever(autoreverses: false)) {
                cloudPhase = 1
            }
            withAnimation(.easeInOut(duration: 4.5).repeatForever(autoreverses: true)) {
                breathe = 1
            }
        }
        .onChange(of: progress) { _, _ in updateCamera() }
    }

    private func windowPane(in size: CGSize) -> some View {
        Map(position: $cameraPosition) {
            MapPolyline(
                coordinates: RouteGeometry.sampledPath(
                    from: session.route.origin.coordinate,
                    to: session.route.destination.coordinate,
                    samples: 48
                )
            )
            .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
        .mapStyle(.imagery(elevation: .realistic))
        .mapControls { }
        .scaleEffect(1.0 + breathe * 0.012)
        .frame(width: size.width * 0.86, height: size.height * 0.72)
        .clipShape(RoundedRectangle(cornerRadius: 42, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.55), radius: 24, y: 10)
        .offset(y: -18)
        .allowsHitTesting(false)
    }

    private var atmosphereWash: some View {
        RoundedRectangle(cornerRadius: 42, style: .continuous)
            .fill(
                LinearGradient(
                    colors: AtmosphereEngine.washColors(for: atmosphere),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 28)
            .padding(.vertical, 110)
            .blendMode(.plusLighter)
            .allowsHitTesting(false)
    }

    private func driftingAtmosphere(in size: CGSize) -> some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Capsule()
                    .fill(.white.opacity(atmosphere == .night ? 0.03 : 0.08))
                    .frame(width: size.width * (0.22 + CGFloat(i) * 0.07), height: 12 + CGFloat(i) * 2)
                    .offset(
                        x: (cloudPhase - 0.5) * (40 + CGFloat(i) * 18),
                        y: -size.height * 0.18 + CGFloat(i) * 34
                    )
                    .blur(radius: 2.5)
            }
            if atmosphere == .rain {
                ForEach(0..<16, id: \.self) { i in
                    Capsule()
                        .fill(.white.opacity(0.14))
                        .frame(width: 1.4, height: 12)
                        .offset(
                            x: CGFloat((i * 41) % 220) - 110,
                            y: CGFloat((i * 29) % 180) - 90 + cloudPhase * 20
                        )
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func plasticWindowFrame(in size: CGSize) -> some View {
        ZStack {
            // Outer bevel
            RoundedRectangle(cornerRadius: 48, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color(white: 0.55), Color(white: 0.18), Color(white: 0.35)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 16
                )
                .frame(width: size.width * 0.90, height: size.height * 0.76)
                .offset(y: -18)
                .shadow(color: .black.opacity(0.5), radius: 10)

            // Inner lip
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 2)
                .frame(width: size.width * 0.84, height: size.height * 0.70)
                .offset(y: -18)

            // Shade handle
            Capsule()
                .fill(Color.white.opacity(0.22))
                .frame(width: 70, height: 7)
                .offset(y: -size.height * 0.34)
        }
        .allowsHitTesting(false)
    }

    private var bottomReadout: some View {
        VStack {
            Spacer()
            VStack(spacing: 7) {
                Text("\(session.route.originIATA) → \(session.route.destinationIATA)")
                    .font(CEFont.body(15, weight: .semibold))
                    .foregroundStyle(.white)

                Text("\(TimeFormatting.clock(remaining)) verbleibend")
                    .font(CEFont.mono(13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))

                Capsule()
                    .fill(.white.opacity(0.12))
                    .frame(width: 130, height: 3)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.85))
                            .frame(width: max(4, 130 * progress), height: 3)
                    }

                Text(String(format: "Reiseflughöhe · %.0f km · %@", flownKilometers, atmosphere.title))
                    .font(CEFont.body(11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .padding(.bottom, 28)
        }
        .allowsHitTesting(false)
    }

    private func updateCamera() {
        let pose = RouteGeometry.cameraPose(
            mode: .window,
            origin: session.route.origin.coordinate,
            destination: session.route.destination.coordinate,
            progress: progress,
            scenario: session.scenario
        )
        cameraPosition = .camera(
            MapCamera(
                centerCoordinate: pose.center,
                distance: min(pose.distance, 9_500),
                heading: heading + 18 + Double(breathe) * 2,
                pitch: 68
            )
        )
    }
}
