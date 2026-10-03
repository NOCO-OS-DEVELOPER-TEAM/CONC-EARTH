import SwiftUI

struct TicketView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var store: SessionStore

    @State private var dragOffset: CGSize = .zero
    @State private var flipped = false
    @State private var appeared = false

    var body: some View {
        ZStack {
            mapBackdrop

            VStack(spacing: 0) {
                HStack {
                    GlassCircleButton(systemName: "chevron.left") {
                        coordinator.backFromTicket()
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()

                ticketStack
                    .padding(.horizontal, 28)
                    .offset(y: appeared ? 0 : 40)
                    .opacity(appeared ? 1 : 0)

                Spacer()

                VStack(spacing: 14) {
                    HStack {
                        HStack(spacing: 10) {
                            ZStack {
                                Circle().fill(CEColor.duskOrange)
                                Image(systemName: "airplane")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .frame(width: 28, height: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Focus Mode")
                                    .font(CEFont.body(14, weight: .semibold))
                                    .foregroundStyle(.white)
                                Text("Stay present · no app blocking claimed")
                                    .font(CEFont.body(11))
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        }
                        Spacer()
                        Text("Edit")
                            .font(CEFont.body(13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .onTapGesture { coordinator.backFromTicket() }
                    }

                    PrimaryPillButton(title: "Boarding") {
                        coordinator.openBoarding()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.84)) {
                appeared = true
            }
        }
    }

    private var mapBackdrop: some View {
        ZStack {
            CEColor.earthDeep
            LinearGradient(
                colors: [CEColor.nightBlue.opacity(0.8), CEColor.earthDeep],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }

    private var ticketStack: some View {
        VStack(spacing: 16) {
            ticketCard
                .rotation3DEffect(.degrees(flipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .offset(dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = CGSize(width: value.translation.width * 0.2, height: value.translation.height * 0.15)
                        }
                        .onEnded { value in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                dragOffset = .zero
                                if abs(value.translation.width) > 80 {
                                    flipped.toggle()
                                }
                            }
                        }
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                        flipped.toggle()
                    }
                }

            barcodeStub
                .rotationEffect(.degrees(-8))
                .offset(y: appeared ? 0 : 20)
        }
    }

    @ViewBuilder
    private var ticketCard: some View {
        ZStack {
            if flipped {
                boardingPassBack.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            } else {
                boardingPassFront
            }
        }
    }

    private var boardingPassFront: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(white: 0.12))
                ticketMapPattern.opacity(0.22)
                VStack(spacing: 22) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(coordinator.selectedRoute?.originIATA ?? "—")
                                .font(CEFont.display(36, weight: .bold))
                            Text(coordinator.selectedRoute?.origin.city ?? "")
                                .font(CEFont.body(14))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                        Spacer()
                        VStack(spacing: 4) {
                            Image(systemName: "airplane")
                                .font(.system(size: 14, weight: .semibold))
                            Text(TimeFormatting.minutesLabel(coordinator.focusMinutes))
                                .font(CEFont.mono(12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.65))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(coordinator.selectedRoute?.destinationIATA ?? "—")
                                .font(CEFont.display(36, weight: .bold))
                            Text(coordinator.selectedRoute?.destination.city ?? "")
                                .font(CEFont.body(14))
                                .foregroundStyle(.white.opacity(0.55))
                        }
                    }
                    .foregroundStyle(.white)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 18) {
                        ticketField("Passenger", store.passengerName)
                        ticketField("Seat", coordinator.selectedSeat?.displayCode ?? "—")
                        ticketField("Distance", coordinator.draftDistanceLabel)
                        ticketField("Flight", coordinator.selectedRoute?.flightNumber ?? "—")
                        ticketField("Boarding", "Now")
                        ticketField("Scenario", coordinator.selectedScenario.title)
                    }
                }
                .padding(22)
            }
            .frame(height: 280)

            ticketNotch
        }
    }

    private var boardingPassBack: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(CEBrand.name)
                .font(CEFont.body(14, weight: .bold))
                .foregroundStyle(CEColor.horizonTeal)
            Text("Boarding Pass")
                .font(CEFont.display(28, weight: .bold))
                .foregroundStyle(.white)
            Text(CEBrand.tagline)
                .font(CEFont.body(14))
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            Text("Aircraft \(coordinator.selectedRoute?.aircraftType ?? "—")")
                .font(CEFont.body(13))
                .foregroundStyle(.white.opacity(0.7))
            Text("Drag or tap to flip")
                .font(CEFont.body(12))
                .foregroundStyle(.white.opacity(0.4))
        }
        .padding(22)
        .frame(maxWidth: .infinity, minHeight: 300, alignment: .leading)
        .background(Color(white: 0.12), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var ticketNotch: some View {
        HStack {
            Circle().fill(CEColor.earthDeep).frame(width: 18, height: 18).offset(x: -9)
            Rectangle()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .foregroundStyle(.white.opacity(0.2))
                .frame(height: 1)
            Circle().fill(CEColor.earthDeep).frame(width: 18, height: 18).offset(x: 9)
        }
        .padding(.vertical, 2)
    }

    private var barcodeStub: some View {
        HStack(spacing: 3) {
            ForEach(0..<28, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1)
                    .fill(.white)
                    .frame(width: CGFloat((i * 7) % 5 + 1), height: CGFloat((i * 13) % 28 + 18))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.black, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var ticketMapPattern: some View {
        GeometryReader { geo in
            Path { path in
                for x in stride(from: 0, through: geo.size.width, by: 18) {
                    for y in stride(from: 0, through: geo.size.height, by: 18) {
                        path.addEllipse(in: CGRect(x: x, y: y, width: 1.5, height: 1.5))
                    }
                }
            }
            .fill(Color.white.opacity(0.35))
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func ticketField(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(CEFont.body(11))
                .foregroundStyle(.white.opacity(0.45))
            Text(value)
                .font(CEFont.body(16, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
