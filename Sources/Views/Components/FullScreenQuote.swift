import SwiftUI

struct FullScreenQuote: View {
    let quote: Quote
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar: Category
                HStack {
                    Spacer()
                    Text(quote.category?.isEmpty == false ? quote.category! : "WISDOM")
                        .font(.system(size: 13, weight: .bold, design: .default))
                        .foregroundColor(.white.opacity(0.4))
                        .textCase(.uppercase)
                        .tracking(4)
                    Spacer()
                }
                .padding(.top, 70) // Clearance for Dynamic Island
                
                Spacer()
                
                // Main Quote Content
                VStack(spacing: 24) {
                    Text("\"\(quote.text)\"")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundColor(.white)
                        .lineSpacing(8)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 32)
                    
                    if let author = quote.author, !author.isEmpty {
                        Text("— \(author)")
                            .font(.system(size: 18, weight: .medium, design: .default))
                            .foregroundColor(.white.opacity(0.6))
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
