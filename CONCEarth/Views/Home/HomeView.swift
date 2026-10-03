import MapKit
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var store: SessionStore
    @EnvironmentObject private var journey: JourneyStore

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5, longitude: 10.0),
            span: MKCoordinateSpan(latitudeDelta: 18, longitudeDelta: 18)
        )
    )

    private var snapshot: JourneySnapshot {
        journey.snapshot(from: store)
    }

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                Annotation(coordinator.homeAirport.city, coordinate: coordinator.homeAirport.coordinate) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.16))
                            .frame(width: 78, height: 78)
                        Circle()
                            .stroke(.white.opacity(0.45), lineWidth: 1)
                            .frame(width: 48, height: 48)
                        Circle()
                            .fill(CEColor.ink)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                }
            }
            .mapStyle(.imagery(elevation: .realistic))
            .mapControls { }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 1.1)) {
                    cameraPosition = .camera(
                        MapCamera(
                            centerCoordinate: coordinator.homeAirport.coordinate,
                            distance: 420_000,
                            heading: 12,
                            pitch: 48
                        )
                    )
                }
            }

            LinearGradient(
                colors: [.black.opacity(0.55), .clear, .black.opacity(0.68)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(TimeFormatting.greeting())
                        .font(CEFont.body(16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.65))
                    Text(coordinator.homeAirport.city)
                        .font(CEFont.display(42, weight: .bold))
                        .foregroundStyle(.white)
                    Text(CEBrand.tagline)
                        .font(CEFont.body(14, weight: .medium))
                        .foregroundStyle(CEColor.horizonTeal)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)

                Spacer()

                VStack(spacing: 12) {
                    GlassPillButton(title: "Start a Flight") {
                        coordinator.beginJourney()
                    }
                    Button {
                        coordinator.openTakeMeSomewhere()
                    } label: {
                        Text("Take me somewhere")
                            .font(CEFont.body(15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 18)

                bottomPanel
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
            }
        }
    }

    private var bottomPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            panelRow(title: "Your Journey", subtitle: "\(snapshot.flights) flights · \(String(format: "%.0f km", snapshot.miles))") {
                coordinator.openJourney()
            }
            Divider().overlay(Color.white.opacity(0.1))
            panelRow(title: "Your World", subtitle: "\(snapshot.destinations) destinations explored") {
                coordinator.openWorld()
            }
            Divider().overlay(Color.white.opacity(0.1))
            panelRow(title: "FlightLog", subtitle: TimeFormatting.shortDuration(snapshot.focusSeconds) + " focused") {
                coordinator.openFlightLog()
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.07), lineWidth: 1)
        )
    }

    private func panelRow(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(CEFont.body(16, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(CEFont.body(12))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.35))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
        }
        .buttonStyle(.plain)
    }
}
