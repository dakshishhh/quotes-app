import SwiftUI

@main
struct DailyQuoteApp: App {
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.easeOut(duration: 0.6)) {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    MainTabView()
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

struct SplashView: View {
    @State private var scale = 0.8
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Image(systemName: "quote.opening")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0)) {
                        scale = 1.0
                        opacity = 1.0
                    }
                }
        }
    }
}
