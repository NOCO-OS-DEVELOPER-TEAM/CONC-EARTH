import SwiftUI

/// Top-down jet. Nose points UP at heading 0. Rotate by map course (degrees clockwise from north).
struct PlaneMarker: View {
    /// Course over ground in degrees (0 = north). When the map camera already faces this course, pass 0.
    let heading: Double
    var showBadge: Bool = false
    var scale: CGFloat = 1

    var body: some View {
        ZStack {
            // Contrails behind the tail (toward bottom when nose is up)
            HStack(spacing: 6 * scale) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.65), .white.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2.8 * scale, height: 52 * scale)
                    .blur(radius: 0.5)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.5), .white.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 2.4 * scale, height: 44 * scale)
                    .blur(radius: 0.7)
            }
            .offset(y: 30 * scale)

            JetSilhouette()
                .fill(Color.white)
                .overlay {
                    JetSilhouette()
                        .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                }
                .frame(width: 36 * scale, height: 42 * scale)
                .shadow(color: .black.opacity(0.5), radius: 3, y: 1)

            if showBadge {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(CEColor.aviationYellow)
                    .frame(width: 15 * scale, height: 15 * scale)
                    .overlay {
                        Image(systemName: "airplane")
                            .font(.system(size: 7 * scale, weight: .bold))
                            .foregroundStyle(CEColor.ink)
                            .rotationEffect(.degrees(-90))
                    }
                    .offset(y: -26 * scale)
            }
        }
        // MapKit Annotation views stay screen-fixed; rotate jet to match course.
        .rotationEffect(.degrees(heading))
        .allowsHitTesting(false)
    }
}

/// Clear top-down airliner: nose at TOP of the shape.
struct JetSilhouette: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var p = Path()

        // Nose
        p.move(to: CGPoint(x: w * 0.50, y: h * 0.02))
        p.addQuadCurve(
            to: CGPoint(x: w * 0.58, y: h * 0.22),
            control: CGPoint(x: w * 0.57, y: h * 0.08)
        )
        // Right wing
        p.addLine(to: CGPoint(x: w * 0.96, y: h * 0.46))
        p.addLine(to: CGPoint(x: w * 0.96, y: h * 0.52))
        p.addLine(to: CGPoint(x: w * 0.60, y: h * 0.46))
        // Right stabilizer
        p.addLine(to: CGPoint(x: w * 0.58, y: h * 0.72))
        p.addLine(to: CGPoint(x: w * 0.74, y: h * 0.88))
        p.addLine(to: CGPoint(x: w * 0.74, y: h * 0.93))
        p.addLine(to: CGPoint(x: w * 0.50, y: h * 0.84))
        // Left stabilizer
        p.addLine(to: CGPoint(x: w * 0.26, y: h * 0.93))
        p.addLine(to: CGPoint(x: w * 0.26, y: h * 0.88))
        p.addLine(to: CGPoint(x: w * 0.42, y: h * 0.72))
        // Left wing
        p.addLine(to: CGPoint(x: w * 0.40, y: h * 0.46))
        p.addLine(to: CGPoint(x: w * 0.04, y: h * 0.52))
        p.addLine(to: CGPoint(x: w * 0.04, y: h * 0.46))
        p.addLine(to: CGPoint(x: w * 0.42, y: h * 0.22))
        p.addQuadCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.02),
            control: CGPoint(x: w * 0.43, y: h * 0.08)
        )
        p.closeSubpath()
        return p
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
