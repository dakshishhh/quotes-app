import SwiftUI

struct FullScreenQuote: View {
    let quote: Quote
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Quote")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .foregroundColor(.white.opacity(0.5))
                        .textCase(.uppercase)
                        .tracking(2)
                    
                    Spacer()
                }
                .padding(.top, 60) // Dynamic Island clearance
                
                Spacer()
                
                Text("\"\(quote.text)\"")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .lineSpacing(8)
                    .multilineTextAlignment(.leading)
                    .minimumScaleFactor(0.5)
                
                if let author = quote.author, !author.isEmpty {
                    Text("— \(author)")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 4)
                }
                
                Spacer()
                
                Spacer().frame(height: 60) // Bottom home bar clearance
            }
            .padding(.horizontal, 32)
        }
    }
}
