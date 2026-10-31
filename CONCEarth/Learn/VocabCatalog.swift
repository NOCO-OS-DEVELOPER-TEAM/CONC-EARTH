import Foundation

struct VocabEntry: Identifiable, Hashable, Codable {
    let id: String
    let de: String
    let en: [String]
    let category: String

    var primaryEN: String { en[0] }

    func acceptsEnglish(_ answer: String) -> Bool {
        let normalized = Self.normalize(answer)
        return en.contains { Self.normalize($0) == normalized }
    }

    func acceptsGerman(_ answer: String) -> Bool {
        Self.normalize(answer) == Self.normalize(de)
    }

    static func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "ä", with: "ae")
            .replacingOccurrences(of: "ö", with: "oe")
            .replacingOccurrences(of: "ü", with: "ue")
            .replacingOccurrences(of: "ß", with: "ss")
            .replacingOccurrences(of: "’", with: "'")
            .replacingOccurrences(of: "–", with: "-")
    }
}

enum VocabCatalog {
    /// Expandable vocabulary packs. Seed pack: childcare / vocational English.
    static let all: [VocabEntry] = [
        .init(id: "v01", de: "Schulungskurs", en: ["training course"], category: "Arbeit"),
        .init(id: "v02", de: "Geschwister", en: ["siblings"], category: "Familie"),
        .init(id: "v03", de: "Termin", en: ["appointment"], category: "Alltag"),
        .init(id: "v04", de: "Jobcenter", en: ["job centre", "job center"], category: "Arbeit"),
        .init(id: "v05", de: "Berufsberater", en: ["job advisor"], category: "Arbeit"),
        .init(id: "v06", de: "Qualifikationen", en: ["qualifications"], category: "Bildung"),
        .init(id: "v07", de: "Zertifikat, Zeugnis", en: ["certificate"], category: "Bildung"),
        .init(id: "v08", de: "Noten", en: ["grades"], category: "Bildung"),
        .init(id: "v09", de: "soziale Kompetenzen", en: ["social skills"], category: "Bildung"),
        .init(id: "v10", de: "Kindergarten", en: ["nursery school", "kindergarten"], category: "Kinder"),
        .init(id: "v11", de: "Kindergärtnerin", en: ["nursery nurse"], category: "Kinder"),
        .init(id: "v12", de: "Weiterbildungseinrichtung", en: ["college of further education"], category: "Bildung"),
        .init(id: "v13", de: "Berufsausbildung", en: ["vocational training"], category: "Bildung"),
        .init(id: "v14", de: "Berufserfahrung", en: ["work experience"], category: "Arbeit"),
        .init(id: "v15", de: "Prüfung, Klausur", en: ["exam", "test"], category: "Bildung"),
        .init(id: "v16", de: "Beruf", en: ["profession"], category: "Arbeit"),
        .init(id: "v17", de: "Sich um jemanden kümmern", en: ["to look after", "to care for"], category: "Kinder"),
        .init(id: "v18", de: "Aufgabe", en: ["task"], category: "Arbeit"),
        .init(id: "v19", de: "Ausflug", en: ["outing"], category: "Kinder"),
        .init(id: "v20", de: "Erste Hilfe leisten", en: ["to give first aid"], category: "Gesundheit"),
        .init(id: "v21", de: "gesund", en: ["healthy"], category: "Gesundheit"),
        .init(id: "v22", de: "angenehm", en: ["pleasant"], category: "Alltag"),
        .init(id: "v23", de: "Umfeld, Umgebung", en: ["environment"], category: "Alltag"),
        .init(id: "v24", de: "geeignet", en: ["suitable"], category: "Alltag"),
        .init(id: "v25", de: "Verwaltungsarbeit", en: ["administrative paperwork"], category: "Arbeit"),
        .init(id: "v26", de: "Entwicklung, Weiterentwicklung", en: ["development"], category: "Bildung"),
        .init(id: "v27", de: "Ernährung", en: ["nutrition"], category: "Gesundheit"),
        .init(id: "v28", de: "Basteln, Kunsthandwerke", en: ["arts and crafts"], category: "Kinder"),
        .init(id: "v29", de: "Sozialdienste", en: ["social services"], category: "Arbeit"),
        .init(id: "v30", de: "Arbeit, Beschäftigung", en: ["work", "employment"], category: "Arbeit"),
        .init(id: "v31", de: "Praktikum", en: ["placement"], category: "Arbeit"),
        .init(id: "v32", de: "Krippe", en: ["crèche", "creche"], category: "Kinder"),
        .init(id: "v33", de: "sich auf etwas freuen", en: ["to look forward to"], category: "Alltag"),
        .init(id: "v34", de: "Antrag, Anmeldung, Bewerbung", en: ["application"], category: "Arbeit"),
        .init(id: "v35", de: "Broschüre, Prospekt", en: ["brochure"], category: "Alltag"),
        .init(id: "v36", de: "Tagesmutter/vater", en: ["childminder"], category: "Kinder"),
        .init(id: "v37", de: "eine registrierte Tagesmutter/vater", en: ["registered childminder"], category: "Kinder"),
        .init(id: "v38", de: "eine ausgebildete Kinderpflegerin", en: ["qualified nursery nurse"], category: "Kinder"),
        .init(id: "v39", de: "eine qualifizierte Kinderpflegerin", en: ["trained nursery nurse"], category: "Kinder"),
        .init(id: "v40", de: "eine staatlich anerkannte Kinderpflegerin", en: ["state-approved nursery nurse"], category: "Kinder"),
        .init(id: "v41", de: "offene Stelle", en: ["vacancy"], category: "Arbeit"),
        .init(id: "v42", de: "Eine vegetarische Mahlzeit", en: ["vegetarian meal"], category: "Gesundheit"),
        .init(id: "v43", de: "Spielzeug", en: ["toys"], category: "Kinder"),
        .init(id: "v44", de: "Ruheraum für ein Nickerchen", en: ["quiet room for a nap"], category: "Kinder"),
        .init(id: "v45", de: "Bewusstsein, Wahrnehmung", en: ["awareness", "perception"], category: "Bildung"),
        .init(id: "v46", de: "Kleinkind", en: ["toddler"], category: "Kinder"),
        .init(id: "v47", de: "Sauberkeitserziehung", en: ["potty training"], category: "Kinder"),
        .init(id: "v48", de: "Bio-Lebensmittel", en: ["organic food"], category: "Gesundheit"),
        .init(id: "v49", de: "Benehmen, Handlungsweise", en: ["behaviour", "behavior"], category: "Kinder"),
        .init(id: "v50", de: "Manieren", en: ["manners"], category: "Kinder"),
        .init(id: "v51", de: "Bezug, Referenz", en: ["reference"], category: "Arbeit"),
        .init(id: "v52", de: "Kinderarzt", en: ["paediatrician", "pediatrician"], category: "Gesundheit"),
        .init(id: "v53", de: "Windel wechseln", en: ["change diapers", "change nappies"], category: "Kinder"),
        .init(id: "v54", de: "beaufsichtigen, aufpassen", en: ["to supervise"], category: "Kinder")
    ]

    static func entry(id: String) -> VocabEntry? {
        all.first { $0.id == id }
    }

    static func distractors(for entry: VocabEntry, count: Int, english: Bool) -> [String] {
        let pool = all.filter { $0.id != entry.id }.shuffled()
        if english {
            return Array(pool.prefix(count).map(\.primaryEN))
        }
        return Array(pool.prefix(count).map(\.de))
    }
}
