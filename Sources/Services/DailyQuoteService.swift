import Foundation
import WidgetKit
import UIKit
import UserNotifications

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
        UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }
    
    @Published var currentDailyQuote: Quote?
    
    init() {
        if let text = sharedDefaults?.string(forKey: quoteTextKey) {
            let author = sharedDefaults?.string(forKey: quoteAuthorKey)
            let category = sharedDefaults?.string(forKey: quoteCategoryKey)
            self.currentDailyQuote = Quote(text: text, author: author, category: category)
        }
        
        // Listen for day changes or app wakes to refresh if needed
        NotificationCenter.default.addObserver(forName: UIApplication.significantTimeChangeNotification, object: nil, queue: .main) { [weak self] _ in
            self?.checkAndUpdateDailyQuote()
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.checkAndUpdateDailyQuote()
        }
        
        checkAndUpdateDailyQuote()
    }
    
    func checkAndUpdateDailyQuote() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let lastUpdated = sharedDefaults?.string(forKey: dateKey)
        
        if lastUpdated != today {
            Task {
                do {
                    let quotes = try await SupabaseService.shared.fetchQuotes()
                    self.updateDailyQuoteIfNeeded(quotes: quotes)
                } catch {
                    print("Failed to fetch quotes for daily update: \(error)")
                }
            }
        }
    }
    
    func updateDailyQuoteIfNeeded(quotes: [Quote]) {
        guard !quotes.isEmpty else { return }
        
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        let lastUpdated = sharedDefaults?.string(forKey: dateKey)
        
        if lastUpdated != today {
            // Pick a random quote
            let randomQuote = quotes.randomElement()!
            
            self.currentDailyQuote = randomQuote
            
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
        
        self.currentDailyQuote = quote
        
        sharedDefaults?.set(today, forKey: dateKey)
        sharedDefaults?.set(quote.text, forKey: quoteTextKey)
        sharedDefaults?.set(quote.author ?? "Unknown", forKey: quoteAuthorKey)
        sharedDefaults?.set(quote.category ?? "Personal", forKey: quoteCategoryKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // Schedule local push notification
    func scheduleDailyNotification(at time: Date, isEnabled: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["daily_quote_notification"])
        
        guard isEnabled else { return }
        
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Today's Quote"
                
                DispatchQueue.main.async {
                    if let quote = self.currentDailyQuote {
                        content.body = "\"\(quote.text)\"\n— \(quote.author ?? "Unknown")"
                    } else {
                        content.body = "Open the app to see your quote of the day."
                    }
                    content.sound = .default
                    
                    let calendar = Calendar.current
                    var dateComponents = calendar.dateComponents([.hour, .minute], from: time)
                    dateComponents.second = 0
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    let request = UNNotificationRequest(identifier: "daily_quote_notification", content: content, trigger: trigger)
                    
                    center.add(request) { error in
                        if let error = error {
                            print("Error scheduling daily quote notification: \(error)")
                        }
                    }
                }
            }
        }
    }
}
