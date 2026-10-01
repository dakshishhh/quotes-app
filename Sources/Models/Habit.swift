import Foundation
import SwiftData

@Model
final class Habit: Identifiable, Codable {
    enum CodingKeys: String, CodingKey {
        case id, userId, title, activeDays, target, reminderTime, lastCompletedDate, completedDates, createdAt, updatedAt
    }
    
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.userId = try container.decodeIfPresent(UUID.self, forKey: .userId)
        self.title = try container.decode(String.self, forKey: .title)
        self.activeDays = try container.decode([Int].self, forKey: .activeDays)
        self.target = try container.decode(String.self, forKey: .target)
        self.reminderTime = try container.decodeIfPresent(Date.self, forKey: .reminderTime)
        self.lastCompletedDate = try container.decodeIfPresent(Date.self, forKey: .lastCompletedDate)
        self.completedDates = try container.decodeIfPresent([String].self, forKey: .completedDates) ?? []
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encode(title, forKey: .title)
        try container.encode(activeDays, forKey: .activeDays)
        try container.encode(target, forKey: .target)
        try container.encodeIfPresent(reminderTime, forKey: .reminderTime)
        try container.encodeIfPresent(lastCompletedDate, forKey: .lastCompletedDate)
        try container.encode(completedDates, forKey: .completedDates)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
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
