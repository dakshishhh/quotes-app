import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var appState = AppState.shared
    
    var body: some View {
        ZStack {
            // Main Content
            ZStack {
                if selectedTab == 0 {
                    FeedView()
                } else if selectedTab == 1 {
                    HabitTrackerView()
                } else if selectedTab == 2 {
                    ReflectView()
                } else if selectedTab == 3 {
                    VaultView()
                } else if selectedTab == 4 {
                    BreatheView()
                }
            }
            .animation(nil, value: selectedTab)
            
            // Custom Floating Tab Bar
            if !appState.hideTabBar {
                VStack {
                    Spacer()
                
                HStack(spacing: 12) {
                    TabItem(
                        icon: "square.stack",
                        title: "Feed",
                        isSelected: selectedTab == 0
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = 0
                        }
                    }
                    
                    TabItem(
                        icon: "list.bullet",
                        title: "Routines",
                        isSelected: selectedTab == 1
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = 1
                        }
                    }
                    
                    TabItem(
                        icon: "text.alignleft",
                        title: "Reflect",
                        isSelected: selectedTab == 2
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = 2
                        }
                    }
                    
                    TabItem(
                        icon: "bookmark",
                        title: "Vault",
                        isSelected: selectedTab == 3
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = 3
                        }
                    }
                    
                    TabItem(
                        icon: "wind",
                        title: "Breathe",
                        isSelected: selectedTab == 4
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = 4
                        }
                    }
                }
                .padding(6)
                .background(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.bottom, 30)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

struct TabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                
                if isSelected {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                        .fixedSize()
                }
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            .padding(.horizontal, isSelected ? 16 : 12)
            .padding(.vertical, 12)
            .background(isSelected ? Color.white.opacity(0.15) : Color.clear)
            .clipShape(Capsule())
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
