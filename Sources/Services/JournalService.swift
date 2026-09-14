import Foundation
import Combine

public struct JournalEntry: Identifiable, Codable, Hashable {
    public let id: String
    public let date: Date
    public let quotePrompt: String? // "Amor Fati"
    public let author: String?
    public let text: String
    
    public init(id: String = UUID().uuidString, date: Date = Date(), quotePrompt: String? = nil, author: String? = nil, text: String) {
        self.id = id
        self.date = date
        self.quotePrompt = quotePrompt
        self.author = author
        self.text = text
    }
}

class JournalService: ObservableObject {
    static let shared = JournalService()
    
    @Published var entries: [JournalEntry] = []
    
    private let journalKey = "journal_entries"
    private var userDefaults: UserDefaults
    
    init() {
        self.userDefaults = UserDefaults(suiteName: "group.com.personal.quotes") ?? UserDefaults.standard
        loadEntries()
    }
    
    func loadEntries() {
        if let data = userDefaults.data(forKey: journalKey),
           let saved = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            self.entries = saved.sorted(by: { $0.date > $1.date }) // Newest first
        }
    }
    
    func addEntry(text: String, quote: Quote?) {
        let entry = JournalEntry(
            quotePrompt: quote?.text,
            author: quote?.author,
            text: text
        )
        entries.insert(entry, at: 0)
        saveEntries()
    }
    
    func removeEntry(_ id: String) {
        entries.removeAll(where: { $0.id == id })
        saveEntries()
    }
    
    private func saveEntries() {
        if let data = try? JSONEncoder().encode(entries) {
            userDefaults.set(data, forKey: journalKey)
        }
    }
}
