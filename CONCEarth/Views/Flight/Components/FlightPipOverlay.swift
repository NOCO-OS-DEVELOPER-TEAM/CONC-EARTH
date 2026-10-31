import MapKit
import SwiftUI

/// Mini live flight preview shown while learning — like a floating “video” tile.
struct FlightPipOverlay: View {
    @EnvironmentObject private var store: SessionStore
    @EnvironmentObject private var timer: FocusTimerService
    @EnvironmentObject private var coordinator: AppCoordinator

    @State private var cameraPosition: MapCameraPosition = .automatic

    private var session: FocusSession? { store.activeSession }

    private var progress: Double {
        session?.progress(at: timer.now) ?? 0
    }

    var body: some View {
        Group {
            if let session, store.activeSession != nil {
                Button {
                    coordinator.returnToFlightFromLearn()
                } label: {
                    ZStack(alignment: .bottomLeading) {
                        Map(position: $cameraPosition) {
                            let path = RouteGeometry.sampledPath(
                                from: session.route.origin.coordinate,
                                to: session.route.destination.coordinate,
                                samples: 40
                            )
                            MapPolyline(coordinates: path)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1.5)

                            let flown = max(2, Int(Double(path.count - 1) * progress) + 1)
                            MapPolyline(coordinates: Array(path.prefix(flown)))
                                .stroke(Color.white.opacity(0.9), lineWidth: 2)

                            Annotation("", coordinate: RouteGeometry.point(
                                from: session.route.origin.coordinate,
                                to: session.route.destination.coordinate,
                                progress: progress
                            )) {
                                PlaneMarker(
                                    heading: 0,
                                    showBadge: false,
                                    scale: 0.55
                                )
                            }
                        }
                        .mapStyle(.imagery(elevation: .realistic))
                        .mapControls { }
                        .allowsHitTesting(false)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(session.route.originIATA)→\(session.route.destinationIATA)")
                                .font(CEFont.body(10, weight: .bold))
                            Text(TimeFormatting.clock(session.remainingSeconds(at: timer.now)))
                                .font(CEFont.mono(11, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(8)
                        .shadow(radius: 2)
                    }
                    .frame(width: 118, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
                }
                .buttonStyle(.plain)
                .onAppear { updateCamera(session: session) }
                .onChange(of: progress) { _, _ in updateCamera(session: session) }
                .onChange(of: timer.now) { _, _ in updateCamera(session: session) }
            }
        }
    }

    private func updateCamera(session: FocusSession) {
        let pose = RouteGeometry.cameraPose(
            mode: .follow,
            origin: session.route.origin.coordinate,
            destination: session.route.destination.coordinate,
            progress: progress,
            scenario: session.scenario
        )
        cameraPosition = .camera(
            MapCamera(
                centerCoordinate: pose.center,
                distance: 12_000,
                heading: pose.heading,
                pitch: 55
            )
        )
    }
}
