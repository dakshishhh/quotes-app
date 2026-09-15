import SwiftUI

struct OnboardingView: View {
    @AppStorage("has_completed_onboarding") var hasCompletedOnboarding = false
    @State private var currentTab = 0
    
    // Animation states
    @State private var showText1 = false
    @State private var showText2 = false
    @State private var showText3 = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentTab) {
                // Page 1
                VStack(spacing: 24) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .opacity(showText1 ? 1 : 0)
                        .offset(y: showText1 ? 0 : 20)
                    
                    Text("Amor Fati")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(showText1 ? 1 : 0)
                        .offset(y: showText1 ? 0 : 20)
                    
                    Text("A daily sanctuary for your mind. A curated quote, a space to reflect, and the tools to build your ideal self.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showText1 ? 1 : 0)
                        .offset(y: showText1 ? 0 : 20)
                }
                .tag(0)
                
                // Page 2
                VStack(spacing: 32) {
                    VStack(alignment: .leading, spacing: 24) {
                        FeatureRow(icon: "square.stack", title: "Feed", desc: "Start with a new piece of wisdom daily.")
                        FeatureRow(icon: "list.bullet", title: "Routines", desc: "Build consistency with a GitHub-style tracker.")
                        FeatureRow(icon: "text.alignleft", title: "Reflect", desc: "Journal directly onto the quote to clear your mind.")
                        FeatureRow(icon: "wind", title: "Breathe", desc: "Find your center with procedural zen chimes.")
                    }
                    .padding(.horizontal, 32)
                    .opacity(showText2 ? 1 : 0)
                    .offset(y: showText2 ? 0 : 20)
                }
                .tag(1)
                
                // Page 3
                VStack(spacing: 24) {
                    Image(systemName: "bell.badge")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                        .opacity(showText3 ? 1 : 0)
                        .offset(y: showText3 ? 0 : 20)
                    
                    Text("Stay Connected")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(showText3 ? 1 : 0)
                        .offset(y: showText3 ? 0 : 20)
                    
                    Text("Enable notifications in your Profile tab to receive your daily quote exactly when you wake up.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .opacity(showText3 ? 1 : 0)
                        .offset(y: showText3 ? 0 : 20)
                    
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        withAnimation {
                            hasCompletedOnboarding = true
                        }
                    }) {
                        Text("Begin")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 40)
                    .opacity(showText3 ? 1 : 0)
                    .offset(y: showText3 ? 0 : 20)
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        }
        .onAppear {
            triggerAnimations(for: currentTab)
        }
        .onChange(of: currentTab) { _, newValue in
            triggerAnimations(for: newValue)
        }
    }
    
    private func triggerAnimations(for tab: Int) {
        if tab == 0 && !showText1 {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) { showText1 = true }
        } else if tab == 1 && !showText2 {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) { showText2 = true }
        } else if tab == 2 && !showText3 {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) { showText3 = true }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let desc: String
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}
