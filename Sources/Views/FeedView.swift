import SwiftUI

struct FeedView: View {
    @State private var quotes: [Quote] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isBouncing = false
    @State private var showChevron = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Text("Oops!")
                        .font(.title)
                        .foregroundColor(.white)
                    Text(error)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await fetchQuotes() }
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if quotes.isEmpty {
                VStack(spacing: 16) {
                    Text("No Quotes Found")
                        .font(.title)
                        .foregroundColor(.white)
                    Text("Please add quotes to your Supabase database.")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(quotes) { quote in
                            FullScreenQuote(quote: quote)
                                .containerRelativeFrame(.vertical)
                                .compositingGroup()
                                .scrollTransition(topLeading: .interactive, bottomTrailing: .interactive, axis: .vertical) { content, phase in
                                    content
                                        .opacity(phase.isIdentity ? 1 : 0)
                                        .rotation3DEffect(
                                            .degrees(phase.value * -25),
                                            axis: (x: 1, y: 0, z: 0),
                                            perspective: 0.8
                                        )
                                        .blur(radius: phase.isIdentity ? 0 : abs(phase.value) * 15)
                                        .scaleEffect(
                                            phase.isIdentity ? 1 : 0.65,
                                            anchor: phase.value < 0 ? .top : .bottom
                                        )
                                        .offset(y: phase.value * 80)
                                }
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
                .ignoresSafeArea()
                
                if showChevron {
                    VStack {
                        Spacer()
                        Image(systemName: "chevron.up")
                            .font(.system(size: 20, weight: .light))
                            .foregroundColor(.white.opacity(0.3))
                            .offset(y: isBouncing ? -10 : 0)
                            .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: isBouncing)
                            .padding(.bottom, 60)
                    }
                    .allowsHitTesting(false)
                    .transition(.opacity)
                    .onAppear {
                        isBouncing = true
                        Task {
                            try? await Task.sleep(nanoseconds: 4_000_000_000)
                            withAnimation(.easeInOut(duration: 1.0)) {
                                showChevron = false
                            }
                        }
                    }
                }
            }
        }
        .task {
            await fetchQuotes()
        }
    }
    
    private func fetchQuotes() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedQuotes = try await SupabaseService.shared.fetchQuotes()
            self.quotes = fetchedQuotes.shuffled() 
            
            if !fetchedQuotes.isEmpty {
                DailyQuoteService.shared.updateDailyQuoteIfNeeded(quotes: fetchedQuotes)
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
