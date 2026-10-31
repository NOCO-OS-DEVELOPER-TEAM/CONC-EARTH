import SwiftUI

/// Top-down jet silhouette with soft contrails — Focus Flight inspired, original asset.
struct PlaneMarker: View {
    let heading: Double
    var showBadge: Bool = true
    var scale: CGFloat = 1

    var body: some View {
        ZStack {
            // Contrails
            HStack(spacing: 7 * scale) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.55), .white.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3.2 * scale, height: 54 * scale)
                    .blur(radius: 0.6)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.45), .white.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2.6 * scale, height: 46 * scale)
                    .blur(radius: 0.8)
            }
            .offset(y: 34 * scale)

            // Jet body
            JetSilhouette()
                .fill(.white)
                .frame(width: 34 * scale, height: 34 * scale)
                .shadow(color: .black.opacity(0.45), radius: 4, y: 2)

            if showBadge {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(CEColor.aviationYellow)
                    .frame(width: 16 * scale, height: 16 * scale)
                    .overlay {
                        Image(systemName: "airplane.departure")
                            .font(.system(size: 8 * scale, weight: .bold))
                            .foregroundStyle(CEColor.ink)
                    }
                    .offset(y: -22 * scale)
            }
        }
        .rotationEffect(.degrees(heading))
        .allowsHitTesting(false)
    }
}

struct JetSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        // Nose pointing up (0°). Heading rotation applied by parent.
        path.move(to: CGPoint(x: w * 0.50, y: h * 0.05))
        path.addLine(to: CGPoint(x: w * 0.58, y: h * 0.28))
        path.addLine(to: CGPoint(x: w * 0.92, y: h * 0.48))
        path.addLine(to: CGPoint(x: w * 0.92, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.60, y: h * 0.48))
        path.addLine(to: CGPoint(x: w * 0.58, y: h * 0.72))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.86))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.92))
        path.addLine(to: CGPoint(x: w * 0.50, y: h * 0.84))
        path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.92))
        path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.86))
        path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.72))
        path.addLine(to: CGPoint(x: w * 0.40, y: h * 0.48))
        path.addLine(to: CGPoint(x: w * 0.08, y: h * 0.55))
        path.addLine(to: CGPoint(x: w * 0.08, y: h * 0.48))
        path.addLine(to: CGPoint(x: w * 0.42, y: h * 0.28))
        path.closeSubpath()
        return path
    }
}

struct AirportRunwayBadge: View {
    var systemName: String = "airplane"

    var body: some View {
        RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(CEColor.aviationYellow)
            .frame(width: 22, height: 22)
            .overlay {
                Image(systemName: systemName)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(CEColor.ink)
            }
            .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
    }
}
