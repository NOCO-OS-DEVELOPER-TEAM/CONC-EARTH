import Foundation

enum LearnExerciseKind: String, CaseIterable, Hashable {
    case multipleChoiceDEToEN
    case multipleChoiceENToDE
    case typeEN
    case typeDE
    case speakEN
}

struct LearnExercise: Identifiable, Hashable {
    let id: UUID
    let kind: LearnExerciseKind
    let entry: VocabEntry
    let prompt: String
    let options: [String]
    let correctAnswer: String

    var instruction: String {
        switch kind {
        case .multipleChoiceDEToEN: return "Wähle die englische Übersetzung"
        case .multipleChoiceENToDE: return "Wähle die deutsche Übersetzung"
        case .typeEN: return "Schreibe auf Englisch"
        case .typeDE: return "Schreibe auf Deutsch"
        case .speakEN: return "Sprich die englische Übersetzung"
        }
    }
}

enum LearnExerciseFactory {
    static func buildLesson(size: Int = 12) -> [LearnExercise] {
        let picks = VocabCatalog.all.shuffled().prefix(size)
        return picks.enumerated().map { index, entry in
            makeExercise(for: entry, variety: index)
        }
    }

    static func makeExercise(for entry: VocabEntry, variety: Int) -> LearnExercise {
        let kinds: [LearnExerciseKind] = [
            .multipleChoiceDEToEN,
            .multipleChoiceENToDE,
            .typeEN,
            .speakEN,
            .typeDE,
            .multipleChoiceDEToEN
        ]
        let kind = kinds[variety % kinds.count]

        switch kind {
        case .multipleChoiceDEToEN:
            let options = ([entry.primaryEN] + VocabCatalog.distractors(for: entry, count: 3, english: true)).shuffled()
            return LearnExercise(
                id: UUID(),
                kind: kind,
                entry: entry,
                prompt: entry.de,
                options: options,
                correctAnswer: entry.primaryEN
            )
        case .multipleChoiceENToDE:
            let options = ([entry.de] + VocabCatalog.distractors(for: entry, count: 3, english: false)).shuffled()
            return LearnExercise(
                id: UUID(),
                kind: kind,
                entry: entry,
                prompt: entry.primaryEN,
                options: options,
                correctAnswer: entry.de
            )
        case .typeEN:
            return LearnExercise(
                id: UUID(),
                kind: kind,
                entry: entry,
                prompt: entry.de,
                options: [],
                correctAnswer: entry.primaryEN
            )
        case .typeDE:
            return LearnExercise(
                id: UUID(),
                kind: kind,
                entry: entry,
                prompt: entry.primaryEN,
                options: [],
                correctAnswer: entry.de
            )
        case .speakEN:
            return LearnExercise(
                id: UUID(),
                kind: kind,
                entry: entry,
                prompt: entry.de,
                options: [],
                correctAnswer: entry.primaryEN
            )
        }
    }
}
