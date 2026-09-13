import Foundation

struct Habit: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var activeDays: Set<Int> // 1...7 (Sunday...Saturday)
    var target: String
    var reminderTime: Date?
    var lastCompletedDate: Date?
    
    init(id: UUID = UUID(), title: String, activeDays: Set<Int> = [1,2,3,4,5,6,7], target: String = "", reminderTime: Date? = nil, lastCompletedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.activeDays = activeDays
        self.target = target
        self.reminderTime = reminderTime
        self.lastCompletedDate = lastCompletedDate
    }
    
    var isCompletedToday: Bool {
        guard let lastCompleted = lastCompletedDate else { return false }
        return Calendar.current.isDateInToday(lastCompleted)
    }
    
    var frequencyText: String {
        if activeDays.count == 7 { return "Everyday" }
        if activeDays == [2,3,4,5,6] { return "Weekdays" }
        if activeDays == [1,7] { return "Weekends" }
        
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let active = activeDays.sorted().map { days[$0 - 1] }
        return active.joined(separator: ", ")
    }
}
