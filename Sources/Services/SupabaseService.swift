import Foundation
import Supabase

let supabaseUrl = URL(string: "https://lgfzpoonabdjcbxoswhs.supabase.co")!
let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxnZnpwb29uYWJkamNieG9zd2hzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkyMDg4OTksImV4cCI6MjEwNDc4NDg5OX0.-nxjaFf7Yd8WnB55Faykv33e23oIMet3sBU3Vf7-l0Y"
let supabase = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)

class SupabaseService {
    static let shared = SupabaseService()
    
    var isConfigured: Bool {
        return true
    }
    
    private let cacheKey = "cached_quotes"
    
    func fetchQuotes() async throws -> [Quote] {
        do {
            // Attempt network fetch
            let remoteQuotes: [Quote] = try await supabase
                .from("quotes")
                .select()
                .execute()
                .value
            
            // Cache 10 random quotes for offline use
            let shuffled = remoteQuotes.shuffled()
            let toCache = Array(shuffled.prefix(10))
            if let data = try? JSONEncoder().encode(toCache) {
                UserDefaults.standard.set(data, forKey: cacheKey)
            }
            
            return remoteQuotes
        } catch {
            // Fallback to offline cache
            if let data = UserDefaults.standard.data(forKey: cacheKey),
               let cachedQuotes = try? JSONDecoder().decode([Quote].self, from: data) {
                return cachedQuotes
            }
            throw error // Only throw if network fails AND no cache exists
        }
    }
}
