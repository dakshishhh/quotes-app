import SwiftUI

@main
struct DailyQuoteApp: App {
    var body: some Scene {
        WindowGroup {
            FeedView()
                .preferredColorScheme(.dark)
        }
    }
}
