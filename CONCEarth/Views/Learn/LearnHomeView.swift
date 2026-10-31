import SwiftUI

struct LearnHomeView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var store: SessionStore

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()
            LinearGradient(
                colors: [CEColor.horizonTeal.opacity(0.18), .clear, CEColor.earthDeep],
                startPoint: .topLeading,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    GlassCircleButton(systemName: "chevron.left") {
                        coordinator.goHome()
                    }
                    Spacer()
                    Text("Lernen")
                        .font(CEFont.body(17, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Englisch an Bord")
                                .font(CEFont.display(30, weight: .bold))
                                .foregroundStyle(.white)
                            Text("54 Vokabeln · Multiple Choice, Tippen & Sprechen.\nDein Flug läuft oben rechts weiter.")
                                .font(CEFont.body(14))
                                .foregroundStyle(.white.opacity(0.55))
                        }

                        lessonCard(
                            title: "Schnelle Lektion",
                            subtitle: "12 Karten · gemischte Übungen",
                            accent: CEColor.horizonTeal
                        ) {
                            coordinator.startLearnLesson(size: 12)
                        }

                        lessonCard(
                            title: "Langer Flug",
                            subtitle: "24 Karten · mehr Tippen & Sprechen",
                            accent: CEColor.duskOrange
                        ) {
                            coordinator.startLearnLesson(size: 24)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Paket")
                                .font(CEFont.body(13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.45))
                            Text("Kinderbetreuung & Berufliches Englisch")
                                .font(CEFont.body(16, weight: .semibold))
                                .foregroundStyle(.white)
                            Text("\(VocabCatalog.all.count) Einträge · später erweiterbar")
                                .font(CEFont.body(12))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 18, style: .continuous))

                        if store.activeSession != nil {
                            Text("Aktiver Flug erkannt — Live-Vorschau bleibt sichtbar.")
                                .font(CEFont.body(12))
                                .foregroundStyle(CEColor.horizonTeal)
                        }
                    }
                    .padding(20)
                }
            }
        }
    }

    private func lessonCard(title: String, subtitle: String, accent: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(CEFont.body(18, weight: .bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(CEFont.body(13))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Circle()
                    .fill(accent.opacity(0.25))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "play.fill")
                            .foregroundStyle(accent)
                    }
            }
            .padding(18)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
