import SwiftUI

struct SeatSelectionView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selected: Seat?
    @State private var appeared = false

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
                    VStack(spacing: 18) {
                        fuselage
                        legend
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 120)
                    .opacity(appeared ? 1 : 0)
                    .scaleEffect(appeared ? 1 : 0.96)
                }

                VStack(spacing: 10) {
                    if let selected {
                        Text(selected.unlocksWindowView ? "Fensterplatz · Window View freigeschaltet" : "Gangplatz · \(selected.displayCode)")
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

    private var fuselage: some View {
        VStack(spacing: 14) {
            // Nose / cockpit
            ZStack {
                UnevenRoundedRectangle(topLeadingRadius: 90, bottomLeadingRadius: 18, bottomTrailingRadius: 18, topTrailingRadius: 90)
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 240, height: 96)
                HStack(spacing: 16) {
                    Capsule().fill(Color.white.opacity(0.18)).frame(width: 30, height: 12)
                    Capsule().fill(Color.white.opacity(0.18)).frame(width: 30, height: 12)
                }
                .offset(y: -26)
            }

            HStack(spacing: 18) {
                ForEach(SeatMapLayout.leftColumns, id: \.self) { Text($0).frame(width: 48) }
                Color.clear.frame(width: 28)
                ForEach(SeatMapLayout.rightColumns, id: \.self) { Text($0).frame(width: 48) }
            }
            .font(CEFont.mono(12, weight: .semibold))
            .foregroundStyle(.white.opacity(0.4))

            ForEach(SeatMapLayout.rows, id: \.self) { row in
                HStack(spacing: 18) {
                    ForEach(SeatMapLayout.leftColumns, id: \.self) { letter in
                        seatButton(Seat(row: row, letter: letter))
                    }
                    Text(String(format: "%02d", row))
                        .font(CEFont.mono(11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.35))
                        .frame(width: 28)
                    ForEach(SeatMapLayout.rightColumns, id: \.self) { letter in
                        seatButton(Seat(row: row, letter: letter))
                    }
                }
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color.white.opacity(0.035))
                .frame(width: 300)
        )
    }

    private func seatButton(_ seat: Seat) -> some View {
        let isSelected = selected?.id == seat.id
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.78)) { selected = seat }
        } label: {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? CEColor.horizonTeal : Color.white.opacity(0.12))
                .frame(width: 48, height: 48)
                .overlay {
                    if seat.position == .window {
                        Image(systemName: "window.ceiling")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(isSelected ? CEColor.ink : .white.opacity(0.5))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isSelected ? Color.white.opacity(0.8) : Color.clear, lineWidth: 1.5)
                )
                .scaleEffect(isSelected ? 1.06 : 1)
        }
        .buttonStyle(.plain)
    }

    private var legend: some View {
        HStack(spacing: 16) {
            Label("Fenster", systemImage: "window.ceiling")
            Text("·")
            Text("A / F schaltet Window View frei")
        }
        .font(CEFont.body(12))
        .foregroundStyle(.white.opacity(0.45))
    }
}
