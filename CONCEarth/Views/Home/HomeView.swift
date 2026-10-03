import MapKit
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var store: SessionStore

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.5, longitude: 10.0),
            span: MKCoordinateSpan(latitudeDelta: 18, longitudeDelta: 18)
        )
    )
    @State private var menuExpanded = true

    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                Annotation(coordinator.homeAirport.city, coordinate: coordinator.homeAirport.coordinate) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.18))
                            .frame(width: 86, height: 86)
                        Circle()
                            .stroke(.white.opacity(0.55), lineWidth: 1)
                            .frame(width: 54, height: 54)
                        Circle()
                            .fill(CEColor.ink)
                            .frame(width: 14, height: 14)
                            .overlay(Circle().stroke(.white, lineWidth: 2))
                    }
                }
            }
            .mapStyle(.imagery(elevation: .realistic))
            .mapControls { }
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2)) {
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
                colors: [.black.opacity(0.55), .clear, .black.opacity(0.65)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(TimeFormatting.greeting())
                        .font(CEFont.body(16, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                    Text(coordinator.homeAirport.city)
                        .font(CEFont.display(42, weight: .bold))
                        .foregroundStyle(.white)
                    Text(CEBrand.tagline)
                        .font(CEFont.body(14, weight: .medium))
                        .foregroundStyle(CEColor.horizonTeal)
                        .padding(.top, 2)
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)

                Spacer()

                GlassPillButton(title: "Start a Flight") {
                    coordinator.beginJourney()
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
            panelRow(title: "FlightLog", subtitle: "\(store.completedSessions.count) flights") {
                coordinator.openFlightLog()
            }
            Divider().overlay(Color.white.opacity(0.12))
            panelRow(
                title: "Total Focus Time",
                subtitle: TimeFormatting.shortDuration(store.totalFocusSeconds)
            ) {
                coordinator.openFlightLog()
            }
            Divider().overlay(Color.white.opacity(0.12))
            panelRow(
                title: CEBrand.name,
                subtitle: CEBrand.subtitle
            ) {
                menuExpanded.toggle()
            }
        }
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
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
                        .font(CEFont.body(13))
                        .foregroundStyle(.white.opacity(0.55))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}
