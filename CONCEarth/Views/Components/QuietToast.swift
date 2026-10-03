import SwiftUI

struct DestinationUnlockToast: View {
    let airport: Airport

    var body: some View {
        VStack(spacing: 10) {
            Text("New destination")
                .font(CEFont.body(12, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
            Text(airport.displayTitle)
                .font(CEFont.display(28, weight: .bold))
                .foregroundStyle(.white)
            Text(airport.iata)
                .font(CEFont.mono(14, weight: .semibold))
                .foregroundStyle(CEColor.horizonTeal)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct AchievementToast: View {
    let achievement: AchievementID

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(achievement.title)
                .font(CEFont.body(15, weight: .semibold))
                .foregroundStyle(.white)
            Text(achievement.subtitle)
                .font(CEFont.body(12))
                .foregroundStyle(.white.opacity(0.55))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .frame(maxWidth: 320, alignment: .leading)
        .background(.ultraThinMaterial, in: Capsule())
    }
}
