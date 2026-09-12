import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    let appGroupIdentifier = "group.com.personal.quotes"
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), quote: "Discipline is choosing between what you want now and what you want most.", author: "Abraham Lincoln", category: "Personal")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = getDailyQuoteEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = getDailyQuoteEntry()
        
        let calendar = Calendar.current
        let midnight = calendar.startOfDay(for: Date()).addingTimeInterval(86400)
        
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
    
    private func getDailyQuoteEntry() -> SimpleEntry {
        let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier)
        let text = sharedDefaults?.string(forKey: "daily_quote_text") ?? "Open the app to fetch your daily quote."
        let author = sharedDefaults?.string(forKey: "daily_quote_author") ?? ""
        let category = sharedDefaults?.string(forKey: "daily_quote_category") ?? "Personal"
        
        return SimpleEntry(date: Date(), quote: text, author: author, category: category)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let quote: String
    let author: String
    let category: String
}

// Static version of the mesh background for the widget
struct WidgetMeshBackground: View {
    var body: some View {
        ZStack {
            Color.black
            
            Circle()
                .fill(Color(white: 0.15))
                .frame(width: 250)
                .blur(radius: 80)
                .offset(x: 50, y: -80)
            
            Circle()
                .fill(Color(white: 0.12))
                .frame(width: 300)
                .blur(radius: 100)
                .offset(x: -80, y: 120)
            
            Circle()
                .fill(Color(white: 0.2))
                .frame(width: 150)
                .blur(radius: 60)
                .offset(x: -20, y: -20)
        }
    }
}

struct DailyQuoteWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        ZStack {
            WidgetMeshBackground()
            
            switch family {
            case .systemSmall:
                SmallWidgetView(entry: entry)
            case .systemMedium:
                MediumWidgetView(entry: entry)
            case .accessoryRectangular:
                LockScreenWidgetView(entry: entry)
            default:
                MediumWidgetView(entry: entry)
            }
        }
        .widgetURL(URL(string: "quotes://daily")) 
    }
}

struct SmallWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "quote.opening")
                .foregroundColor(.white.opacity(0.5))
                .font(.system(size: 14))
            
            Text(entry.quote)
                .font(.system(size: 16, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .lineLimit(4)
                .minimumScaleFactor(0.7)
            
            Spacer(minLength: 0)
        }
        .padding()
    }
}

struct MediumWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text("Today's Quote")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if !entry.author.isEmpty && entry.author != "Unknown" {
                    Text(entry.author)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            Text("\"\(entry.quote)\"")
                .font(.system(size: 20, weight: .bold, design: .default))
                .foregroundColor(.white)
                .lineLimit(3)
                .minimumScaleFactor(0.7)
            
            Spacer(minLength: 0)
            
            Text("Daily quote · Changes once per day")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
    }
}

struct LockScreenWidgetView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.quote)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .lineLimit(3)
                .minimumScaleFactor(0.8)
        }
    }
}

@main
struct DailyQuoteWidget: Widget {
    let kind: String = "DailyQuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DailyQuoteWidgetEntryView(entry: entry)
                    .containerBackground(Color.clear, for: .widget)
            } else {
                DailyQuoteWidgetEntryView(entry: entry)
                    .padding()
                    .background(Color.clear)
            }
        }
        .configurationDisplayName("Daily Quote")
        .description("Displays a beautiful daily quote.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}
