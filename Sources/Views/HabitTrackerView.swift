import SwiftUI
import UIKit

struct HabitTrackerView: View {
    @StateObject private var habitService = HabitService.shared
    @State private var showAddModal = false
    @State private var habitToEdit: Habit?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Layer 1: The Quote (Background)
            VStack {
                if let dailyQuote = DailyQuoteService.shared.currentDailyQuote {
                    Text("\"\(dailyQuote.text)\"")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                    
                    Text("— \(dailyQuote.author)")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 24)
                } else {
                    Text("\"Do not dwell in the past, do not dream of the future, concentrate the mind on the present moment.\"")
                        .font(.system(size: 28, weight: .bold, design: .default))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                    
                    Text("— Buddha")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 24)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .zIndex(0)
            
            // Layer 2: Habits (Foreground)
            VStack(spacing: 0) {
                // Top Bar
                VStack(spacing: 30) {
                    // Weekly Calendar
                    HStack {
                        ForEach(0..<7) { i in
                            let date = Calendar.current.date(byAdding: .day, value: i - 3, to: Date())!
                            let isToday = Calendar.current.isDateInToday(date)
                            let isPast = date < Date() && !isToday
                            let letter = ["S", "M", "T", "W", "T", "F", "S"][Calendar.current.component(.weekday, from: date) - 1]
                            
                            VStack(spacing: 8) {
                                Text(letter)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.3))
                                
                                ZStack {
                                    Circle()
                                        .strokeBorder(isToday ? Color.white.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 2)
                                        .background(Circle().fill(isPast ? Color.white : Color.clear))
                                        .frame(width: 24, height: 24)
                                    
                                    if isPast {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                            if i < 6 { Spacer() }
                        }
                    }
                    .padding(.top, 20) // For dynamic island safe area
                    
                    // Header
                    HStack {
                        Text("TODAY'S ROUTINES")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.4))
                            .letterSpacing(1)
                        
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
                .zIndex(1)
                
                // Habits List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(habitService.habits.filter { !$0.isCompletedToday }) { habit in
                            HabitRow(
                                habit: habit,
                                onComplete: {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        habitService.markHabitCompleted(id: habit.id)
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        
                                        // If this was the last one
                                        if habitService.habits.filter({ !$0.isCompletedToday }).count == 1 {
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
            }
            .zIndex(1)
            .opacity(habitService.habits.filter { !$0.isCompletedToday }.isEmpty ? 0 : 1)
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
                
                HStack(spacing: 6) {
                    Text(habit.frequencyText)
                    if let time = habit.reminderTime {
                        Text("•")
                        Text(time, style: .time)
                    }
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.3))
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
                .frame(height: 1)
                .offset(y: 42),
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
                if let existing = habitToEdit {
                    var updated = existing
                    updated.title = name.isEmpty ? "New Habit" : name
                    updated.activeDays = activeDays
                    updated.target = target
                    updated.reminderTime = enableReminder ? reminderTime : nil
                    habitService.updateHabit(updated)
                } else {
                    let habit = Habit(
                        title: name.isEmpty ? "New Habit" : name,
                        activeDays: activeDays,
                        target: target,
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

extension View {
    func letterSpacing(_ tracking: CGFloat) -> some View {
        if #available(iOS 16.0, *) {
            return self.tracking(tracking)
        } else {
            return self
        }
    }
}
