import Foundation
import Combine

class VaultService: ObservableObject {
    static let shared = VaultService()
    
    @Published var savedQuotes: [Quote] = []
    
    private let vaultKey = "saved_quotes"
    private var userDefaults: UserDefaults
    
    init() {
        self.userDefaults = UserDefaults(suiteName: "group.com.personal.quotes") ?? UserDefaults.standard
        loadQuotes()
    }
    
    func loadQuotes() {
        if let data = userDefaults.data(forKey: vaultKey),
           let quotes = try? JSONDecoder().decode([Quote].self, from: data) {
            self.savedQuotes = quotes
        }
    }
    
    func isSaved(_ quote: Quote) -> Bool {
        return savedQuotes.contains(where: { $0.id == quote.id })
    }
    
    func toggleSave(_ quote: Quote) -> Bool {
        var isNowSaved = false
        if isSaved(quote) {
            savedQuotes.removeAll(where: { $0.id == quote.id })
            isNowSaved = false
        } else {
            savedQuotes.insert(quote, at: 0) // Newest at top
            isNowSaved = true
        }
        
        saveQuotes()
        return isNowSaved
    }
    
    private func saveQuotes() {
        if let data = try? JSONEncoder().encode(savedQuotes) {
            userDefaults.set(data, forKey: vaultKey)
        }
    }
}
