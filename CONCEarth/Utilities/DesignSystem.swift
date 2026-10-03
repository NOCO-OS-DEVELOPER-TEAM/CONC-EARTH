import SwiftUI

enum CEBrand {
    static let name = "CONC EARTH"
    static let subtitle = "Concentration Earth"
    static let tagline = "Focus takes you somewhere."
}

enum CEColor {
    static let earthDeep = Color(red: 0.06, green: 0.08, blue: 0.10)
    static let earthMid = Color(red: 0.12, green: 0.14, blue: 0.16)
    static let fog = Color.white.opacity(0.72)
    static let ink = Color(red: 0.08, green: 0.09, blue: 0.10)
    static let aviationYellow = Color(red: 1.0, green: 0.84, blue: 0.04)
    static let horizonTeal = Color(red: 0.18, green: 0.72, blue: 0.62)
    static let duskOrange = Color(red: 0.95, green: 0.45, blue: 0.22)
    static let nightBlue = Color(red: 0.10, green: 0.16, blue: 0.28)
    static let stormSlate = Color(red: 0.35, green: 0.40, blue: 0.48)
}

enum CEFont {
    static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

struct GlassCircleButton: View {
    let systemName: String
    var filled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(filled ? CEColor.ink : .white)
                .frame(width: 44, height: 44)
                .background {
                    if filled {
                        Circle().fill(.white)
                    } else {
                        Circle().fill(.ultraThinMaterial)
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

struct PrimaryPillButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(CEFont.body(17, weight: .semibold))
                .foregroundStyle(CEColor.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(isEnabled ? Color.white : Color.white.opacity(0.35))
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

struct GlassPillButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(CEFont.body(17, weight: .semibold))
                .foregroundStyle(CEColor.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(.regularMaterial)
                )
        }
        .buttonStyle(.plain)
    }
}
