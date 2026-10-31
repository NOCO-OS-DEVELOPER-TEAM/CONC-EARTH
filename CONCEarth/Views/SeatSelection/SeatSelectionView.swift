import SwiftUI

struct SeatSelectionView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selected: Seat?
    @State private var appeared = false

    private let cabinWidth: CGFloat = 292
    private let seatSize: CGFloat = 40
    private let seatGap: CGFloat = 8
    private let aisleWidth: CGFloat = 28

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    GlassCircleButton(systemName: "chevron.left") {
                        coordinator.backFromSeat()
                    }
                    Spacer()
                    Text("Sitzplatz")
                        .font(CEFont.body(16, weight: .semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        cabin
                        Text("Fensterplätze A und F schalten die Fensteransicht frei.")
                            .font(CEFont.body(12))
                            .foregroundStyle(.white.opacity(0.45))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                    .opacity(appeared ? 1 : 0)
                }

                VStack(spacing: 10) {
                    if let selected {
                        Text(selected.unlocksWindowView
                             ? "Fensterplatz \(selected.displayCode) · Fensteransicht aktiv"
                             : "Gangplatz \(selected.displayCode)")
                            .font(CEFont.body(13, weight: .medium))
                            .foregroundStyle(selected.unlocksWindowView ? CEColor.horizonTeal : .white.opacity(0.6))
                    }
                    PrimaryPillButton(title: "Weiter", isEnabled: selected != nil) {
                        if let selected { coordinator.confirmSeat(selected) }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.84)) { appeared = true }
        }
    }

    private var cabin: some View {
        // Keep seats well inside the fuselage side walls (A/F must not hang outside).
        let seatsWidth = seatSize * 4 + seatGap * 3 + aisleWidth
        let sidePadding = max(32, (cabinWidth - seatsWidth) / 2)

        return ZStack(alignment: .top) {
            // Soft nose — aggressive top radius previously clipped A/F outside the hull.
            UnevenRoundedRectangle(
                topLeadingRadius: 48,
                bottomLeadingRadius: 30,
                bottomTrailingRadius: 30,
                topTrailingRadius: 48
            )
            .fill(Color.white.opacity(0.08))
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 48,
                    bottomLeadingRadius: 30,
                    bottomTrailingRadius: 30,
                    topTrailingRadius: 48
                )
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .frame(width: cabinWidth)
            .frame(minHeight: 440)

            VStack(spacing: 12) {
                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 64, height: 8)
                    .padding(.top, 18)

                HStack(spacing: 14) {
                    Capsule().fill(Color.white.opacity(0.18)).frame(width: 28, height: 11)
                    Capsule().fill(Color.white.opacity(0.18)).frame(width: 28, height: 11)
                }

                HStack(spacing: seatGap) {
                    ForEach(SeatMapLayout.leftColumns, id: \.self) { Text($0).frame(width: seatSize) }
                    Color.clear.frame(width: aisleWidth)
                    ForEach(SeatMapLayout.rightColumns, id: \.self) { Text($0).frame(width: seatSize) }
                }
                .font(CEFont.mono(11, weight: .semibold))
                .foregroundStyle(.white.opacity(0.4))
                .padding(.horizontal, sidePadding)

                ForEach(SeatMapLayout.rows, id: \.self) { row in
                    HStack(spacing: seatGap) {
                        ForEach(SeatMapLayout.leftColumns, id: \.self) { letter in
                            seatButton(Seat(row: row, letter: letter))
                        }
                        Text(String(format: "%02d", row))
                            .font(CEFont.mono(10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.35))
                            .frame(width: aisleWidth)
                        ForEach(SeatMapLayout.rightColumns, id: \.self) { letter in
                            seatButton(Seat(row: row, letter: letter))
                        }
                    }
                    .padding(.horizontal, sidePadding)
                }

                Spacer(minLength: 28)
            }
            .padding(.bottom, 22)
        }
        .frame(width: cabinWidth)
    }

    private func seatButton(_ seat: Seat) -> some View {
        let isSelected = selected?.id == seat.id
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) { selected = seat }
        } label: {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(isSelected ? CEColor.horizonTeal : Color.white.opacity(0.14))
                .frame(width: seatSize, height: seatSize)
                .overlay {
                    if seat.position == .window {
                        Image(systemName: "window.ceiling")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(isSelected ? CEColor.ink : .white.opacity(0.55))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .stroke(isSelected ? Color.white.opacity(0.85) : Color.clear, lineWidth: 1.5)
                )
                .scaleEffect(isSelected ? 1.05 : 1)
        }
        .buttonStyle(.plain)
    }
}
