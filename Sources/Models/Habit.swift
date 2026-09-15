import Foundation
import SwiftData

@Model
final class Habit: Identifiable {
    @Attribute(.unique) var id: UUID
    var userId: UUID? // The Supabase Auth User ID
    var title: String
    var activeDays: [Int] // 1...7 (Sunday...Saturday)
    var target: String
    var reminderTime: Date?
    var lastCompletedDate: Date?
    var completedDates: [String]? // YYYY-MM-DD
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), userId: UUID? = nil, title: String, activeDays: [Int] = [1,2,3,4,5,6,7], target: String = "", reminderTime: Date? = nil, lastCompletedDate: Date? = nil, completedDates: [String]? = nil, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.title = title
        self.activeDays = activeDays
        self.target = target
        self.reminderTime = reminderTime
        self.lastCompletedDate = lastCompletedDate
        self.completedDates = completedDates ?? []
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func markCompleted() {
        self.lastCompletedDate = Date()
        self.updatedAt = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        if self.completedDates == nil {
            self.completedDates = []
        }
        if let completed = self.completedDates, !completed.contains(todayStr) {
            self.completedDates?.append(todayStr)
        }
    }
    
    func isCompletedOn(date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        return completedDates?.contains(dateStr) ?? false
    }
    
    var isCompletedToday: Bool {
        guard let lastCompleted = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(lastCompleted)
    }
    
    var frequencyText: String {
        let activeSet = Set(activeDays)
        if activeSet.count == 7 { return "Everyday" }
        if activeSet == [2,3,4,5,6] { return "Weekdays" }
        if activeSet == [1,7] { return "Weekends" }
        
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let active = activeDays.sorted().map { days[$0 - 1] }
        return active.joined(separator: ", ")
    }
}

// DTO for Supabase Sync
struct HabitDTO: Codable {
    var id: UUID
    var user_id: UUID
    var title: String
    var active_days: [Int]
    var target: String?
    var reminder_time: Date?
    var last_completed_date: Date?
    var completed_dates: [String]?
    var created_at: Date?
    var updated_at: Date?
    
    init(from habit: Habit, userId: UUID) {
        self.id = habit.id
        self.user_id = userId
        self.title = habit.title
        self.active_days = habit.activeDays
        self.target = habit.target.isEmpty ? nil : habit.target
        self.reminder_time = habit.reminderTime
        self.last_completed_date = habit.lastCompletedDate
        self.completed_dates = habit.completedDates
        self.created_at = habit.createdAt
        self.updated_at = habit.updatedAt
    }
}
