import Combine
import Foundation

@MainActor
final class LearnSessionStore: ObservableObject {
    @Published private(set) var exercises: [LearnExercise] = []
    @Published private(set) var index: Int = 0
    @Published private(set) var correctCount: Int = 0
    @Published private(set) var answeredCount: Int = 0
    @Published var lastFeedback: String?
    @Published var isComplete = false
    @Published var typedAnswer: String = ""
    @Published var selectedOption: String?
    @Published var speakHeard: String = ""

    var current: LearnExercise? {
        guard exercises.indices.contains(index) else { return nil }
        return exercises[index]
    }

    var progress: Double {
        guard !exercises.isEmpty else { return 0 }
        return Double(answeredCount) / Double(exercises.count)
    }

    func startLesson(size: Int = 12) {
        exercises = LearnExerciseFactory.buildLesson(size: size)
        index = 0
        correctCount = 0
        answeredCount = 0
        isComplete = false
        lastFeedback = nil
        typedAnswer = ""
        selectedOption = nil
        speakHeard = ""
    }

    func submitMultipleChoice(_ option: String) {
        guard let current else { return }
        selectedOption = option
        let ok = VocabEntry.normalize(option) == VocabEntry.normalize(current.correctAnswer)
            || (current.kind == .multipleChoiceDEToEN && current.entry.acceptsEnglish(option))
            || (current.kind == .multipleChoiceENToDE && current.entry.acceptsGerman(option))
        finish(correct: ok, expected: current.correctAnswer)
    }

    func submitTyped() {
        guard let current else { return }
        let ok: Bool
        switch current.kind {
        case .typeEN, .speakEN:
            ok = current.entry.acceptsEnglish(typedAnswer)
        case .typeDE:
            ok = current.entry.acceptsGerman(typedAnswer)
        default:
            ok = VocabEntry.normalize(typedAnswer) == VocabEntry.normalize(current.correctAnswer)
        }
        finish(correct: ok, expected: current.correctAnswer)
    }

    func submitSpoken(_ transcript: String) {
        speakHeard = transcript
        typedAnswer = transcript
        submitTyped()
    }

    func advance() {
        lastFeedback = nil
        typedAnswer = ""
        selectedOption = nil
        speakHeard = ""
        if index + 1 >= exercises.count {
            isComplete = true
        } else {
            index += 1
        }
    }

    private func finish(correct: Bool, expected: String) {
        answeredCount += 1
        if correct {
            correctCount += 1
            lastFeedback = "Richtig"
        } else {
            lastFeedback = "Lösung: \(expected)"
        }
    }
}
