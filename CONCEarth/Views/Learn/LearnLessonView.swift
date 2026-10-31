import SwiftUI

struct LearnLessonView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var learn: LearnSessionStore
    @StateObject private var speech = SpeechPracticeService()

    var body: some View {
        ZStack(alignment: .topTrailing) {
            CEColor.earthDeep.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                progressBar
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                if learn.isComplete {
                    completion
                } else if let exercise = learn.current {
                    exerciseBody(exercise)
                }

                Spacer(minLength: 0)
            }

            FlightPipOverlay()
                .padding(.top, 56)
                .padding(.trailing, 14)
        }
        .onDisappear { speech.stop() }
    }

    private var header: some View {
        HStack {
            GlassCircleButton(systemName: "xmark") {
                speech.stop()
                coordinator.exitLearn()
            }
            Spacer()
            Text("Lektion")
                .font(CEFont.body(16, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Text("\(learn.correctCount)/\(max(learn.answeredCount, 1))")
                .font(CEFont.mono(12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.5))
                .frame(width: 44, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.1))
                Capsule()
                    .fill(CEColor.horizonTeal)
                    .frame(width: max(8, geo.size.width * learn.progress))
            }
        }
        .frame(height: 8)
    }

    @ViewBuilder
    private func exerciseBody(_ exercise: LearnExercise) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(exercise.instruction)
                .font(CEFont.body(13, weight: .medium))
                .foregroundStyle(.white.opacity(0.45))
                .padding(.top, 22)

            Text(exercise.prompt)
                .font(CEFont.display(28, weight: .bold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)

            Text(exercise.entry.category.uppercased())
                .font(CEFont.body(11, weight: .semibold))
                .foregroundStyle(CEColor.horizonTeal)

            Group {
                switch exercise.kind {
                case .multipleChoiceDEToEN, .multipleChoiceENToDE:
                    multipleChoice(exercise)
                case .typeEN, .typeDE:
                    typingPad(exercise)
                case .speakEN:
                    speakPad(exercise)
                }
            }
            .padding(.top, 8)

            if let feedback = learn.lastFeedback {
                feedbackBar(feedback)
            }
        }
        .padding(.horizontal, 20)
        .padding(.trailing, 120) // keep clear of PiP
    }

    private func multipleChoice(_ exercise: LearnExercise) -> some View {
        VStack(spacing: 10) {
            ForEach(exercise.options, id: \.self) { option in
                Button {
                    guard learn.lastFeedback == nil else { return }
                    learn.submitMultipleChoice(option)
                } label: {
                    Text(option)
                        .font(CEFont.body(16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(optionBackground(option), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(learn.lastFeedback != nil)
            }

            if learn.lastFeedback != nil {
                PrimaryPillButton(title: "Weiter") { learn.advance() }
                    .padding(.top, 8)
            }
        }
    }

    private func typingPad(_ exercise: LearnExercise) -> some View {
        VStack(spacing: 12) {
            TextField("Antwort eingeben", text: $learn.typedAnswer)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(16)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(.white)
                .disabled(learn.lastFeedback != nil)

            if learn.lastFeedback == nil {
                PrimaryPillButton(title: "Prüfen", isEnabled: !learn.typedAnswer.trimmingCharacters(in: .whitespaces).isEmpty) {
                    learn.submitTyped()
                }
            } else {
                PrimaryPillButton(title: "Weiter") { learn.advance() }
            }
        }
    }

    private func speakPad(_ exercise: LearnExercise) -> some View {
        VStack(spacing: 14) {
            Text(speech.transcript.isEmpty ? "Tippe aufs Mikrofon und sprich Englisch" : speech.transcript)
                .font(CEFont.body(15))
                .foregroundStyle(.white.opacity(0.7))
                .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                .padding(14)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))

            HStack(spacing: 12) {
                Button {
                    if speech.isListening {
                        speech.stop()
                    } else {
                        speech.start()
                    }
                } label: {
                    Image(systemName: speech.isListening ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(speech.isListening ? CEColor.duskOrange : CEColor.horizonTeal)
                }
                .buttonStyle(.plain)

                if learn.lastFeedback == nil {
                    PrimaryPillButton(title: "Auswerten", isEnabled: !speech.transcript.isEmpty) {
                        speech.stop()
                        learn.submitSpoken(speech.transcript)
                    }
                } else {
                    PrimaryPillButton(title: "Weiter") {
                        speech.stop()
                        learn.advance()
                    }
                }
            }

            if speech.authorizationDenied {
                Text("Mikrofon/Spracherkennung nicht erlaubt — tippe die Antwort stattdessen.")
                    .font(CEFont.body(12))
                    .foregroundStyle(.white.opacity(0.45))
                TextField("Fallback tippen", text: $learn.typedAnswer)
                    .padding(12)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(.white)
                if learn.lastFeedback == nil {
                    Button("Tippen prüfen") { learn.submitTyped() }
                        .foregroundStyle(CEColor.horizonTeal)
                }
            }
        }
    }

    private func feedbackBar(_ text: String) -> some View {
        HStack {
            Image(systemName: text == "Richtig" ? "checkmark.circle.fill" : "info.circle.fill")
            Text(text)
                .font(CEFont.body(14, weight: .semibold))
        }
        .foregroundStyle(text == "Richtig" ? CEColor.horizonTeal : CEColor.duskOrange)
        .padding(.top, 6)
    }

    private func optionBackground(_ option: String) -> Color {
        guard let feedback = learn.lastFeedback, let current = learn.current else {
            return Color.white.opacity(0.08)
        }
        let selected = learn.selectedOption == option
        let isCorrect = VocabEntry.normalize(option) == VocabEntry.normalize(current.correctAnswer)
            || current.entry.acceptsEnglish(option)
            || current.entry.acceptsGerman(option)
        if isCorrect { return CEColor.horizonTeal.opacity(0.28) }
        if selected && feedback != "Richtig" { return CEColor.duskOrange.opacity(0.25) }
        return Color.white.opacity(0.06)
    }

    private var completion: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("Lektion geschafft")
                .font(CEFont.display(30, weight: .bold))
                .foregroundStyle(.white)
            Text("\(learn.correctCount) von \(learn.exercises.count) richtig")
                .font(CEFont.body(16))
                .foregroundStyle(.white.opacity(0.55))
            PrimaryPillButton(title: "Fertig") {
                coordinator.exitLearn()
            }
            .padding(.horizontal, 28)
            Spacer()
        }
    }
}
