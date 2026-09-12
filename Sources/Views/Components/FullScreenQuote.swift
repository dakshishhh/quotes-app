import SwiftUI

struct FullScreenQuote: View {
    let quote: Quote
    
    var body: some View {
        ZStack {
            // Transparent background so the FeedView's MeshBackground shows through perfectly
            Color.clear.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Quote")
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                }
                
                Spacer()
                
                Text("\"\(quote.text)\"")
                    .font(.system(size: 32, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.5)
                
                if let author = quote.author, !author.isEmpty {
                    Text("— \(author)")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .padding(32)
        }
    }
}
