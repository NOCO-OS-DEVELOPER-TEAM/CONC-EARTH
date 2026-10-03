import SwiftUI

struct SeatSelectionView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var selected: Seat?
    @State private var appeared = false

    var body: some View {
        ZStack {
            CEColor.earthDeep.ignoresSafeArea()

            RadialGradient(
                colors: [Color.white.opacity(0.08), .clear],
                center: .top,
                startRadius: 20,
                endRadius: 420
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    GlassCircleButton(systemName: "chevron.left") {
                        coordinator.backFromSeat()
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text("Select your seat")
                            .font(CEFont.body(16, weight: .semibold))
                            .foregroundStyle(.white)
                        if let route = coordinator.selectedRoute {
                            Text("\(route.originIATA) → \(route.destinationIATA)")
                                .font(CEFont.body(12))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                    }
                    Spacer()
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        fuselageHeader
                        seatGrid
                        legend
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                    .scaleEffect(appeared ? 1 : 0.94)
                    .opacity(appeared ? 1 : 0)
                }

                VStack(spacing: 10) {
                    if let selected {
                        Text(selected.unlocksWindowView ? "Window seat unlocks Window View" : "\(selected.position.title) seat · \(selected.displayCode)")
                            .font(CEFont.body(13, weight: .medium))
                            .foregroundStyle(selected.unlocksWindowView ? CEColor.horizonTeal : .white.opacity(0.65))
                    }
                    PrimaryPillButton(title: "Continue", isEnabled: selected != nil) {
                        if let selected {
                            coordinator.confirmSeat(selected)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
                .background(
                    LinearGradient(colors: [CEColor.earthDeep.opacity(0), CEColor.earthDeep], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                )
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
                appeared = true
            }
        }
    }

    private var fuselageHeader: some View {
        ZStack {
            UnevenRoundedRectangle(topLeadingRadius: 90, bottomLeadingRadius: 28, bottomTrailingRadius: 28, topTrailingRadius: 90)
                .fill(Color.white.opacity(0.06))
                .frame(width: 260, height: 110)
            HStack(spacing: 18) {
                Capsule().fill(Color.white.opacity(0.18)).frame(width: 34, height: 14)
                Capsule().fill(Color.white.opacity(0.18)).frame(width: 34, height: 14)
            }
            .offset(y: -28)
        }
    }

    private var seatGrid: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                ForEach(["A", "B", "C"], id: \.self) { letter in
                    Text(letter)
                        .font(CEFont.mono(12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.45))
                        .frame(width: 44)
                }
                Color.clear.frame(width: 28)
                ForEach(["D", "E", "F"], id: \.self) { letter in
                    Text(letter)
                        .font(CEFont.mono(12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.45))
                        .frame(width: 44)
                }
            }

            ForEach(SeatMapLayout.rows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(["A", "B", "C"], id: \.self) { letter in
                        seatButton(Seat(row: row, letter: letter))
                    }
                    Text(String(format: "%02d", row))
                        .font(CEFont.mono(11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.35))
                        .frame(width: 28)
                    ForEach(["D", "E", "F"], id: \.self) { letter in
                        seatButton(Seat(row: row, letter: letter))
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 12)
                .animation(.spring(response: 0.45, dampingFraction: 0.85).delay(Double(row) * 0.04), value: appeared)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .frame(width: 320)
        )
    }

    private func seatButton(_ seat: Seat) -> some View {
        let isSelected = selected?.id == seat.id
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selected = seat
            }
        } label: {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? CEColor.horizonTeal : Color.white.opacity(0.12))
                .frame(width: 44, height: 44)
                .overlay {
                    if seat.position == .window {
                        Image(systemName: "window.ceiling")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(isSelected ? CEColor.ink : .white.opacity(0.55))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isSelected ? Color.white.opacity(0.8) : Color.clear, lineWidth: 1.5)
                )
                .scaleEffect(isSelected ? 1.08 : 1)
        }
        .buttonStyle(.plain)
    }

    private var legend: some View {
        HStack(spacing: 16) {
            legendItem(color: CEColor.horizonTeal, text: "Selected")
            legendItem(color: Color.white.opacity(0.12), text: "Available")
            legendItem(icon: "window.ceiling", text: "Window")
        }
        .font(CEFont.body(12))
        .foregroundStyle(.white.opacity(0.6))
    }

    private func legendItem(color: Color? = nil, icon: String? = nil, text: String) -> some View {
        HStack(spacing: 6) {
            if let color {
                RoundedRectangle(cornerRadius: 4).fill(color).frame(width: 14, height: 14)
            }
            if let icon {
                Image(systemName: icon).font(.system(size: 12))
            }
            Text(text)
        }
    }
}
