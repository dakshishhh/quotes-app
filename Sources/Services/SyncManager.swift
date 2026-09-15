import Foundation
import SwiftData
import Supabase
import Combine

@MainActor
class SyncManager: ObservableObject {
    static let shared = SyncManager()
    
    @Published var isSyncing: Bool = false
    @Published var lastSyncError: String? = nil
    
    private init() {}
    
    func sync(context: ModelContext) async {
        guard let userId = AuthManager.shared.currentUser?.id else { return }
        
        isSyncing = true
        lastSyncError = nil
        
        do {
            // 1. Fetch Local Habits
            let fetchDescriptor = FetchDescriptor<Habit>()
            let localHabits = try context.fetch(fetchDescriptor)
            
            // 2. Push Local to Supabase
            for habit in localHabits {
                let dto = HabitDTO(from: habit, userId: userId)
                try await supabase
                    .from("habits")
                    .upsert(dto)
                    .execute()
            }
            
            // 3. Fetch Remote Habits
            let remoteHabits: [HabitDTO] = try await supabase
                .from("habits")
                .select()
                .eq("user_id", value: userId)
                .execute()
                .value
            
            // 4. Upsert Remote into Local
            for remote in remoteHabits {
                if let existing = localHabits.first(where: { $0.id == remote.id }) {
                    // Update existing if remote is newer
                    if let remoteUpdated = remote.updated_at, remoteUpdated > existing.updatedAt {
                        existing.title = remote.title
                        existing.activeDays = remote.active_days
                        existing.target = remote.target ?? ""
                        existing.reminderTime = remote.reminder_time
                        existing.lastCompletedDate = remote.last_completed_date
                        existing.completedDates = remote.completed_dates
                        existing.createdAt = remote.created_at ?? existing.createdAt
                        existing.updatedAt = remote.updated_at ?? existing.updatedAt
                    }
                } else {
                    // Insert new
                    let newHabit = Habit(
                        id: remote.id,
                        userId: remote.user_id,
                        title: remote.title,
                        activeDays: remote.active_days,
                        target: remote.target ?? "",
                        reminderTime: remote.reminder_time,
                        lastCompletedDate: remote.last_completed_date,
                        completedDates: remote.completed_dates,
                        createdAt: remote.created_at ?? Date(),
                        updatedAt: remote.updated_at ?? Date()
                    )
                    context.insert(newHabit)
                }
            }
            
            try context.save()
            
        } catch {
            self.lastSyncError = error.localizedDescription
            print("Sync failed: \(error)")
        }
        
        isSyncing = false
    }
}
