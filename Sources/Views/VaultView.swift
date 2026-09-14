import SwiftUI
import UIKit

struct VaultView: View {
    @StateObject private var vaultService = VaultService.shared
    @State private var selectedQuote: Quote?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if vaultService.savedQuotes.isEmpty {
                VStack {
                    Image(systemName: "bookmark")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.2))
                        .padding(.bottom, 16)
                    Text("Your vault is empty.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        ForEach(vaultService.savedQuotes) { quote in
                            VaultCard(quote: quote)
                                .onTapGesture {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    selectedQuote = quote
                                }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 120) // Tab bar clearance
                }
            }
        }
        .fullScreenCover(item: $selectedQuote) { quote in
            ZStack {
                Color.black.ignoresSafeArea()
                FullScreenQuote(quote: quote)
                
                // Overlay close button
                VStack {
                    HStack {
                        Button(action: {
                            selectedQuote = nil
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(24)
                                .background(Color.black.opacity(0.01))
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

struct VaultCard: View {
    let quote: Quote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("\"\(quote.text)\"")
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundColor(.white)
                .lineSpacing(6)
                .lineLimit(4)
            
            if let author = quote.author, !author.isEmpty {
                Text(author)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
