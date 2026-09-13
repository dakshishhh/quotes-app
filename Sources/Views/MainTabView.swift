import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Main Content
            if selectedTab == 0 {
                FeedView()
            } else {
                HabitTrackerView()
            }
            
            // Custom Floating Tab Bar
            VStack {
                Spacer()
                
                HStack(spacing: 8) {
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
                        title: "Habits",
                        isSelected: selectedTab == 1
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = 1
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
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(isSelected ? Color.white.opacity(0.15) : Color.clear)
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
