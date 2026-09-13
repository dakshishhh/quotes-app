import Foundation
import UserNotifications

class HabitService: ObservableObject {
    static let shared = HabitService()
    
    @Published var habits: [Habit] = []
    private let defaults = UserDefaults.standard
    private let habitsKey = "saved_habits"
    
    init() {
        loadHabits()
    }
    
    func loadHabits() {
        if let data = defaults.data(forKey: habitsKey),
           let savedHabits = try? JSONDecoder().decode([Habit].self, from: data) {
            self.habits = savedHabits
        }
    }
    
    func saveHabits() {
        if let data = try? JSONEncoder().encode(habits) {
            defaults.set(data, forKey: habitsKey)
        }
    }
    
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
        scheduleNotification(for: habit)
    }
    
    func updateHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits[index] = habit
            saveHabits()
            scheduleNotification(for: habit)
        }
    }
    
    func deleteHabit(id: UUID) {
        habits.removeAll { $0.id == id }
        saveHabits()
        cancelNotification(for: id)
    }
    
    func markHabitCompleted(id: UUID) {
        if let index = habits.firstIndex(where: { $0.id == id }) {
            habits[index].lastCompletedDate = Date()
            saveHabits()
        }
    }
    
    // MARK: - Notifications
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleNotification(for habit: Habit) {
        cancelNotification(for: habit.id)
        
        guard let time = habit.reminderTime else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time for your routine"
        content.body = habit.title
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func cancelNotification(for id: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
}
