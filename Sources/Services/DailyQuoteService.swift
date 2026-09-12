import Foundation
import WidgetKit

@MainActor
class DailyQuoteService: ObservableObject {
    static let shared = DailyQuoteService()
    
    // Using the App Group identifier defined in entitlements
    let appGroupIdentifier = "group.com.personal.quotes"
    
    // UserDefaults keys
    let dateKey = "daily_quote_date"
    let quoteTextKey = "daily_quote_text"
    let quoteAuthorKey = "daily_quote_author"
    let quoteCategoryKey = "daily_quote_category"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }
    
    func updateDailyQuoteIfNeeded(quotes: [Quote]) {
        guard !quotes.isEmpty else { return }
        
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let lastUpdated = sharedDefaults?.string(forKey: dateKey)
        
        if lastUpdated != today {
            // Pick a random quote
            let randomQuote = quotes.randomElement()!
            
            // Save to shared defaults
            sharedDefaults?.set(today, forKey: dateKey)
            sharedDefaults?.set(randomQuote.text, forKey: quoteTextKey)
            sharedDefaults?.set(randomQuote.author ?? "Unknown", forKey: quoteAuthorKey)
            sharedDefaults?.set(randomQuote.category ?? "Personal", forKey: quoteCategoryKey)
            
            // Tell Widget to refresh
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // A fallback helper if we want to manually push a quote
    func forceUpdateDailyQuote(quote: Quote) {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        sharedDefaults?.set(today, forKey: dateKey)
        sharedDefaults?.set(quote.text, forKey: quoteTextKey)
        sharedDefaults?.set(quote.author ?? "Unknown", forKey: quoteAuthorKey)
        sharedDefaults?.set(quote.category ?? "Personal", forKey: quoteCategoryKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
