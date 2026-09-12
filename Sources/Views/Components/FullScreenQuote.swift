import SwiftUI

struct FullScreenQuote: View {
    let quote: Quote
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Main Quote Content (perfectly grouped)
                VStack(spacing: 0) {
                    
                    // Eyebrow Category
                    Text(quote.category?.isEmpty == false ? quote.category! : "WISDOM")
                        .font(.system(size: 12, weight: .bold, design: .default))
                        .foregroundColor(.white.opacity(0.4))
                        .textCase(.uppercase)
                        .tracking(5)
                        .padding(.bottom, 40)
                    
                    Text("\"\(quote.text)\"")
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .lineSpacing(8)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 24)
                    
                    if let author = quote.author, !author.isEmpty {
                        Text("— \(author)")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(.white.opacity(0.6))
                            .tracking(0.5)
                    }
                }
                .padding(.bottom, 40) // Optical centering offset
                
                Spacer()
                
                // Bottom spacing for home indicator
                Spacer().frame(height: 40)
            }
        }
    }
}
