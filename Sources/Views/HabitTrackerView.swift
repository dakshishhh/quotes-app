import SwiftUI
import UIKit

struct HabitTrackerView: View {
    @StateObject private var habitService = HabitService.shared
    @StateObject private var dailyQuoteService = DailyQuoteService.shared
    @State private var showAddModal = false
    @State private var habitToEdit: Habit?
    
    // Grid seeded random intensities
    private let pastIntensities: [Double] = (0..<27).map { i in
        // Static seed based on index so it doesn't flicker
        let seededRandom = Double((i * 13) % 100) / 100.0
        return seededRandom < 0.2 ? 0.1 : seededRandom
    }
    
    private var todayWeekday: Int {
        Calendar.current.component(.weekday, from: Date())
    }
    
    private var todayHabits: [Habit] {
        habitService.habits.filter { $0.activeDays.contains(todayWeekday) }
    }
    
    private var totalToday: Int {
        todayHabits.count
    }
    
    private var completedToday: Int {
        todayHabits.filter { $0.isCompletedToday }.count
    }
    
    private var allCompleted: Bool {
        totalToday > 0 && completedToday == totalToday
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Background Reward (The Quote)
            VStack {
                if let dailyQuote = dailyQuoteService.currentDailyQuote {
                    Text("\"\(dailyQuote.text)\"")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                    
                    Text("— \(dailyQuote.author ?? "Unknown")")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 24)
                } else {
                    Text("\"Amor Fati.\"")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                    
                    Text("— Marcus Aurelius")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Blur and opacity based on completion
            .opacity(allCompleted ? 1.0 : 0.0)
            .blur(radius: allCompleted ? 0 : 20)
            .scaleEffect(allCompleted ? 1.0 : 0.9)
            .animation(.spring(response: 1.0, dampingFraction: 0.8), value: allCompleted)
            .zIndex(0)
            
            // Layer 2: Habits (Foreground)
            VStack(spacing: 0) {
                // Header (Fades away when all completed)
                VStack(spacing: 30) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TODAY")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.3))
                                .tracking(2)
                            Text("\(completedToday) / \(totalToday)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // GitHub style grid (4 weeks = 28 days. We show columns of 4 rows, so 7 columns)
                        HStack(spacing: 4) {
                            ForEach(0..<7) { col in
                                VStack(spacing: 4) {
                                    ForEach(0..<4) { row in
                                        let index = col * 4 + row
                                        if index < 27 { // Past days
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.white.opacity(pastIntensities[index]))
                                                .frame(width: 12, height: 12)
                                        } else { // Today (index == 27)
                                            let todayIntensity = totalToday == 0 ? 0.1 : Double(completedToday) / Double(totalToday)
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.white.opacity(max(0.1, todayIntensity)))
                                                .frame(width: 12, height: 12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .stroke(Color.white, lineWidth: 1)
                                                )
                                                .shadow(color: .white.opacity(0.5), radius: 4)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 40)
                    
                    HStack {
                        Text("TODAY'S ROUTINES")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.4))
                            .tracking(1)
                        
                        Spacer()
                        
                        Button(action: {
                            showAddModal = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 28, height: 28)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .background(Color.black)
                .opacity(allCompleted ? 0.0 : 1.0)
                .animation(.easeInOut(duration: 0.5), value: allCompleted)
                .zIndex(1)
                
                // Habits List
                if !allCompleted {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(todayHabits.filter { !$0.isCompletedToday }) { habit in
                                HabitRow(
                                    habit: habit,
                                    onComplete: {
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            habitService.markHabitCompleted(id: habit.id)
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            
                                            // If this was the last one
                                            if todayHabits.filter({ !$0.isCompletedToday }).count == 1 {
                                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                            }
                                        }
                                    },
                                    onEdit: {
                                        habitToEdit = habit
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 120) // Space for tab bar
                    }
                    .background(Color.black)
                    .transition(.opacity)
                } else {
                    Spacer()
                }
            }
            .zIndex(1)
        }
        .sheet(isPresented: $showAddModal) {
            AddHabitSheet(habit: nil)
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(white: 0.07))
        }
        .sheet(item: $habitToEdit) { habit in
            AddHabitSheet(habit: habit)
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(white: 0.07))
        }
        .onAppear {
            habitService.requestNotificationPermission()
        }
        .task {
            if DailyQuoteService.shared.currentDailyQuote == nil {
                if let fetchedQuotes = try? await SupabaseService.shared.fetchQuotes(), !fetchedQuotes.isEmpty {
                    DailyQuoteService.shared.updateDailyQuoteIfNeeded(quotes: fetchedQuotes)
                }
            }
        }
    }
}

// MARK: - Habit Row
struct HabitRow: View {
    let habit: Habit
    let onComplete: () -> Void
    let onEdit: () -> Void
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.95))
                
                if !habit.frequencyText.isEmpty || habit.reminderTime != nil {
                    HStack(spacing: 6) {
                        if !habit.frequencyText.isEmpty {
                            Text(habit.frequencyText)
                        }
                        if let time = habit.reminderTime {
                            if !habit.frequencyText.isEmpty {
                                Text("•")
                            }
                            Text(time, style: .time)
                        }
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
                }
            }
            
            Spacer()
            
            if !habit.target.isEmpty {
                Text(habit.target)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.2))
        }
        .padding(.horizontal, 24)
        .frame(height: 85)
        .background(Color.black)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1),
            alignment: .bottom
        )
        .offset(x: offset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation.width
                }
                .onEnded { value in
                    if value.translation.width > 100 {
                        // Swipe Right -> Complete
                        withAnimation(.easeOut(duration: 0.2)) {
                            offset = UIScreen.main.bounds.width
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            onComplete()
                        }
                    } else if value.translation.width < -100 {
                        // Swipe Left -> Edit
                        withAnimation(.spring()) {
                            offset = 0 // bounce back
                        }
                        onEdit()
                    } else {
                        withAnimation(.spring()) {
                            offset = 0
                        }
                    }
                }
        )
    }
}

// MARK: - Add Habit Sheet
struct AddHabitSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var habitService = HabitService.shared
    
    var habitToEdit: Habit?
    
    @State private var name = ""
    @State private var activeDays: Set<Int> = [1,2,3,4,5,6,7]
    @State private var target = ""
    @State private var reminderTime = Date()
    @State private var enableReminder = false
    
    init(habit: Habit? = nil) {
        self.habitToEdit = habit
        _name = State(initialValue: habit?.title ?? "")
        _activeDays = State(initialValue: habit?.activeDays ?? [1,2,3,4,5,6,7])
        _target = State(initialValue: habit?.target ?? "")
        _reminderTime = State(initialValue: habit?.reminderTime ?? Date())
        _enableReminder = State(initialValue: habit?.reminderTime != nil)
    }
    
    var isEveryday: Bool {
        activeDays.count == 7
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(habitToEdit == nil ? "New Routine" : "Edit Routine")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 24)
            
            // Name
            VStack(alignment: .leading, spacing: 8) {
                Text("HABIT NAME")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                
                TextField("e.g. Read Non-Fiction", text: $name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            
            // Frequency
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("FREQUENCY")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            if isEveryday {
                                activeDays.removeAll()
                            } else {
                                activeDays = [1,2,3,4,5,6,7]
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
                                    .background(RoundedRectangle(cornerRadius: 4).fill(isEveryday ? Color.white : Color.clear))
                                    .frame(width: 18, height: 18)
                                
                                if isEveryday {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundColor(.black)
                                }
                            }
                            Text("Everyday")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                HStack {
                    let days = ["S", "M", "T", "W", "T", "F", "S"]
                    ForEach(1...7, id: \.self) { day in
                        let isActive = activeDays.contains(day)
                        Button(action: {
                            withAnimation {
                                if isActive {
                                    activeDays.remove(day)
                                } else {
                                    activeDays.insert(day)
                                }
                            }
                        }) {
                            Text(days[day - 1])
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(isActive ? .black : .white.opacity(0.4))
                                .frame(width: 36, height: 36)
                                .background(isActive ? Color.white : Color.white.opacity(0.05))
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        if day < 7 { Spacer() }
                    }
                }
            }
            
            // Reminder
            VStack(alignment: .leading, spacing: 8) {
                Text("REMINDER TIME (OPTIONAL)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                
                VStack(spacing: 8) {
                    HStack {
                        Toggle("Enable Reminder", isOn: $enableReminder)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    
                    HStack {
                        Text("Send Notification at")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .colorScheme(.dark)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .opacity(enableReminder ? 1.0 : 0.3)
                    .disabled(!enableReminder)
                }
            }
            
            // Target
            VStack(alignment: .leading, spacing: 8) {
                Text("TARGET (OPTIONAL)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                
                TextField("e.g. 15 pages", text: $target)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
            
            Spacer()
            
            Button(action: {
                let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
                let finalName = trimmedName.isEmpty ? "New Habit" : trimmedName
                let trimmedTarget = target.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let existing = habitToEdit {
                    var updated = existing
                    updated.title = finalName
                    updated.activeDays = activeDays
                    updated.target = trimmedTarget
                    updated.reminderTime = enableReminder ? reminderTime : nil
                    habitService.updateHabit(updated)
                } else {
                    let habit = Habit(
                        title: finalName,
                        activeDays: activeDays,
                        target: trimmedTarget,
                        reminderTime: enableReminder ? reminderTime : nil
                    )
                    habitService.addHabit(habit)
                }
                dismiss()
            }) {
                Text(habitToEdit == nil ? "Create Routine" : "Save Changes")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .cornerRadius(16)
            }
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
    }
}
