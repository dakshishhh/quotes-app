import SwiftUI
import UserNotifications

struct ProfileView: View {
    @State private var selectedTab = 0 // 0 = Vault, 1 = Settings
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header Segmented Control
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation { selectedTab = 0 }
                    }) {
                        Text("Vault")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(selectedTab == 0 ? .black : .white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTab == 0 ? Color.white : Color.clear)
                            .clipShape(Capsule())
                    }
                    
                    Button(action: {
                        withAnimation { selectedTab = 1 }
                    }) {
                        Text("Settings")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(selectedTab == 1 ? .black : .white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedTab == 1 ? Color.white : Color.clear)
                            .clipShape(Capsule())
                    }
                }
                .padding(4)
                .background(Color.white.opacity(0.1))
                .clipShape(Capsule())
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 24)
                
                if selectedTab == 0 {
                    // Embed Vault
                    VaultView(isEmbedded: true)
                } else {
                    SettingsView()
                }
                
                Spacer()
            }
        }
    }
}

struct SettingsView: View {
    @AppStorage("daily_notification_enabled") private var notificationsEnabled = false
    @AppStorage("daily_notification_time") private var notificationTimeDouble = Date().timeIntervalSince1970
    
    private var notificationTime: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSince1970: notificationTimeDouble) },
            set: { newValue in 
                notificationTimeDouble = newValue.timeIntervalSince1970 
                DailyQuoteService.shared.scheduleDailyNotification(at: newValue, isEnabled: notificationsEnabled)
            }
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Notifications Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("DAILY QUOTE NOTIFICATION")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(1.5)
                    
                    VStack(spacing: 0) {
                        Toggle("Enable Push Notifications", isOn: $notificationsEnabled)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .tint(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .onChange(of: notificationsEnabled) { _, newValue in
                                DailyQuoteService.shared.scheduleDailyNotification(at: notificationTime.wrappedValue, isEnabled: newValue)
                            }
                        
                        if notificationsEnabled {
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 16)
                            
                            HStack {
                                Text("Delivery Time")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                DatePicker("", selection: notificationTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .colorScheme(.dark)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                
                // Info Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("ABOUT")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(1.5)
                    
                    VStack(spacing: 0) {
                        Button(action: {
                            // Contact action
                        }) {
                            HStack {
                                Text("Contact Support")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "envelope")
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .padding(16)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.leading, 16)
                        
                        Button(action: {
                            // Export action
                        }) {
                            HStack {
                                Text("Export Journal Data")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.white.opacity(0.3))
                            }
                            .padding(16)
                        }
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                
                // Account Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("ACCOUNT")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(1.5)
                    
                    VStack(spacing: 0) {
                        Button(action: {
                            Task { await AuthManager.shared.signOut() }
                        }) {
                            HStack {
                                Text("Log Out")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(16)
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.leading, 16)
                        
                        Button(action: {
                            Task { await AuthManager.shared.deleteAccount() }
                        }) {
                            HStack {
                                Text("Delete Account")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding(16)
                        }
                    }
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                
                Text("App Version 1.0.0")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.2))
                    .padding(.top, 24)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 120) // Tab bar clearance
        }
    }
}
