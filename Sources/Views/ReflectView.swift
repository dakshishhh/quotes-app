import SwiftUI
import UIKit

struct ReflectView: View {
    @StateObject private var journalService = JournalService.shared
    @StateObject private var appState = AppState.shared
    
    @State private var isGuided = true
    @State private var draftText = ""
    @FocusState private var isEditorFocused: Bool
    
    @State private var showDiscardAlert = false
    @State private var showReadingEntry: JournalEntry?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Toggle and X)
                HStack {
                    if appState.isZenModeActive {
                        Button(action: {
                            if !draftText.isEmpty {
                                showDiscardAlert = true
                            } else {
                                exitZenMode()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                        }
                        .transition(.opacity)
                    } else {
                        Spacer().frame(width: 44)
                    }
                    
                    Spacer()
                    
                    if !appState.isZenModeActive {
                        HStack(spacing: 0) {
                            Button(action: { isGuided = true }) {
                                Text("Guided")
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(isGuided ? Color.white.opacity(0.2) : Color.clear)
                                    .foregroundColor(isGuided ? .white : .white.opacity(0.5))
                                    .clipShape(Capsule())
                            }
                            
                            Button(action: { isGuided = false }) {
                                Text("Free Flow")
                                    .font(.system(size: 13, weight: .semibold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 6)
                                    .background(!isGuided ? Color.white.opacity(0.2) : Color.clear)
                                    .foregroundColor(!isGuided ? .white : .white.opacity(0.5))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(4)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                        .transition(.opacity)
                    }
                    
                    Spacer()
                    Spacer().frame(width: 44) // Balance
                }
                .padding(.horizontal, 24)
                .padding(.top, 16) // Accounts for safe area
                .frame(height: 60)
                
                // Editor Container
                VStack(spacing: 0) {
                    if isGuided {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("TODAY'S PROMPT")
                                .font(.system(size: 12, weight: .bold, design: .default))
                                .foregroundColor(.white.opacity(0.3))
                                .tracking(2)
                            
                            Text("\"Amor Fati.\"") // Placeholder for actual daily quote
                                .font(.system(size: 22, weight: .bold, design: .default))
                                .foregroundColor(.white)
                            
                            Text("— Marcus Aurelius")
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 24)
                        .padding(.top, 24)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    ZStack(alignment: .topLeading) {
                        if draftText.isEmpty {
                            Text(isGuided ? "What did this make you think?" : "Write freely...")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.white.opacity(0.4))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $draftText)
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(.white)
                            .focused($isEditorFocused)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(.top, 16)
                    
                    // Save Button
                    HStack {
                        Spacer()
                        Button(action: saveEntry) {
                            Text("Save")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .clipShape(Capsule())
                        }
                        .opacity(draftText.isEmpty ? 0.5 : 1.0)
                        .disabled(draftText.isEmpty)
                    }
                    .padding(.bottom, 20)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(appState.isZenModeActive ? .clear : .white.opacity(0.1)),
                        alignment: .bottom
                    )
                }
                .padding(.horizontal, 24)
                .frame(maxHeight: appState.isZenModeActive ? .infinity : 350)
                
                // History List
                if !appState.isZenModeActive {
                    VStack(alignment: .leading) {
                        Text("PAST REFLECTIONS")
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .foregroundColor(.white.opacity(0.3))
                            .tracking(2)
                            .padding(.horizontal, 24)
                            .padding(.top, 24)
                            .padding(.bottom, 12)
                        
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(journalService.entries) { entry in
                                    JournalCard(entry: entry)
                                        .onTapGesture {
                                            showReadingEntry = entry
                                        }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 120)
                        }
                    }
                    .transition(.opacity)
                }
                
                Spacer(minLength: 0)
            }
        }
        .onChange(of: isEditorFocused) { focused in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                appState.isZenModeActive = focused
                appState.hideTabBar = focused
            }
        }
        .alert("Discard Entry?", isPresented: $showDiscardAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Discard", role: .destructive) {
                draftText = ""
                exitZenMode()
            }
        }
        .fullScreenCover(item: $showReadingEntry) { entry in
            ReadingView(entry: entry)
        }
    }
    
    private func saveEntry() {
        // Provide haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        journalService.addEntry(
            text: draftText,
            quote: isGuided ? Quote(text: "Amor Fati.", author: "Marcus Aurelius") : nil // Hardcoded for demo
        )
        draftText = ""
        exitZenMode()
    }
    
    private func exitZenMode() {
        isEditorFocused = false
    }
}

struct JournalCard: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.5))
            
            Text(entry.text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.9))
                .lineSpacing(4)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct ReadingView: View {
    let entry: JournalEntry
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(24)
                    }
                    Spacer()
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        Text(entry.date.formatted(date: .complete, time: .shortened))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                        
                        if let prompt = entry.quotePrompt {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\"\(prompt)\"")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white.opacity(0.8))
                                if let author = entry.author {
                                    Text("— \(author)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            .padding(.leading, 16)
                            .overlay(
                                Rectangle()
                                    .frame(width: 2)
                                    .foregroundColor(.white.opacity(0.2)),
                                alignment: .leading
                            )
                        }
                        
                        Text(entry.text)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .lineSpacing(8)
                    }
                    .padding(.horizontal, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button(action: {
                    JournalService.shared.removeEntry(entry.id)
                    dismiss()
                }) {
                    Text("Delete Entry")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.red)
                        .padding(20)
                }
            }
        }
    }
}
