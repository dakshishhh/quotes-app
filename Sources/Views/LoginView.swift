import SwiftUI
import AuthenticationServices
import GoogleSignInSwift

struct LoginView: View {
    @ObservedObject var authManager = AuthManager.shared
    
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        Spacer()
                            .frame(minHeight: 40)
                        
                        // Logo
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .padding(.bottom, 40)
                        
                        // Auth Form
                        VStack(spacing: 16) {
                            TextField("Email", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(14)
                            
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(14)
                            
                            if let errorMessage = authManager.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button(action: {
                                Task {
                                    if isSignUp {
                                        await authManager.signUpWithEmail(email: email, password: password)
                                    } else {
                                        await authManager.signInWithEmail(email: email, password: password)
                                    }
                                }
                            }) {
                                Text(isSignUp ? "Create Account" : "Sign In")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.primary)
                                    .foregroundColor(Color(UIColor.systemBackground))
                                    .cornerRadius(14)
                            }
                            .padding(.top, 4)
                        }
                        
                        // Divider
                        HStack {
                            VStack { Divider() }
                            Text("OR")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                            VStack { Divider() }
                        }
                        .padding(.vertical, 24)
                        
                        // Social Logins
                        VStack(spacing: 16) {
                            SignInWithAppleButton(.continue) { request in
                                authManager.signInWithApple()
                            } onCompletion: { result in
                                // Handled in authManager delegate
                            }
                            .signInWithAppleButtonStyle(UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black)
                            .frame(height: 52)
                            .cornerRadius(14)
                            
                            Button(action: {
                                Task { await authManager.signInWithGoogle() }
                            }) {
                                HStack {
                                    Image(systemName: "g.circle.fill")
                                        .font(.title3)
                                    Text("Continue with Google")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color(UIColor.secondarySystemBackground))
                                .foregroundColor(.primary)
                                .cornerRadius(14)
                            }
                        }
                        
                        Spacer()
                            .frame(minHeight: 40)
                        
                        // Footer toggle
                        Button(action: {
                            withAnimation {
                                isSignUp.toggle()
                            }
                        }) {
                            Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Create one")
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        .padding(.bottom, 20)
                        
                    }
                    .padding(.horizontal, 32)
                    .frame(minHeight: geometry.size.height)
                }
            }
            .navigationBarHidden(true)
            .overlay {
                if authManager.isLoading {
                    ZStack {
                        Color(UIColor.systemBackground).opacity(0.8).ignoresSafeArea()
                        ProgressView()
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
