import SwiftUI

struct FullScreenQuote: View {
    let quote: Quote
    @StateObject private var vaultService = VaultService.shared
    @State private var showToast = false
    @State private var toastMessage = ""
    
    // For sharing
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    
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
                        Text("- \(author)")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(.white.opacity(0.6))
                            .tracking(0.5)
                    }
                }
                .padding(.bottom, 40) // Optical centering offset
                
                // Actions (Save and Share)
                HStack(spacing: 32) {
                    Button(action: {
                        let isSaved = vaultService.toggleSave(quote)
                        showFeedback(message: isSaved ? "Saved to Vault" : "Removed from Vault")
                    }) {
                        Image(systemName: vaultService.isSaved(quote) ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(vaultService.isSaved(quote) ? .white : .white.opacity(0.5))
                            .frame(width: 44, height: 44)
                    }
                    
                    Button(action: shareQuote) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.top, -20)
                
                Spacer()
                
                // Bottom spacing for home indicator
                Spacer().frame(height: 40)
            }
            
            // Minimal Toast
            if showToast {
                VStack {
                    Text(toastMessage)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                        .padding(.top, 50)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showToast)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let img = shareImage {
                ShareSheet(activityItems: [img])
            }
        }
    }
    
    private func showFeedback(message: String) {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        toastMessage = message
        withAnimation { showToast = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showToast = false }
        }
    }
    
    @MainActor
    private func shareQuote() {
        // Create an aesthetic square render of the quote
        let renderer = ImageRenderer(content: ShareableView(quote: quote))
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            self.shareImage = uiImage
            self.showShareSheet = true
        }
    }
}

// Minimal view purely for rendering to Image
struct ShareableView: View {
    let quote: Quote
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                Text(quote.category?.isEmpty == false ? quote.category! : "WISDOM")
                    .font(.system(size: 14, weight: .bold, design: .default))
                    .foregroundColor(.white.opacity(0.4))
                    .textCase(.uppercase)
                    .tracking(5)
                    .padding(.bottom, 40)
                
                Text("\"\(quote.text)\"")
                    .font(.system(size: 34, weight: .bold, design: .default))
                    .foregroundColor(.white)
                    .lineSpacing(8)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
                
                if let author = quote.author, !author.isEmpty {
                    Text("- \(author)")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(0.5)
                }
            }
            .padding(40)
        }
        .frame(width: 1080, height: 1080) // High-res Instagram square format
        .environment(\.colorScheme, .dark)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
