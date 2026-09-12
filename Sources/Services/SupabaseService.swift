import Foundation

class SupabaseService {
    static let shared = SupabaseService()
    
    // Hardcoded credentials for immediate launch
    private let projectURL = "https://lgfzpoonabdjcbxoswhs.supabase.co"
    private let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxnZnpwb29uYWJkamNieG9zd2hzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkyMDg4OTksImV4cCI6MjEwNDc4NDg5OX0.-nxjaFf7Yd8WnB55Faykv33e23oIMet3sBU3Vf7-l0Y"
    
    var isConfigured: Bool {
        return true
    }
    
    func fetchQuotes() async throws -> [Quote] {
        guard let url = URL(string: "\(projectURL)/rest/v1/quotes?select=*") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        if httpResponse.statusCode != 200 {
            print("Error: HTTP \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([Quote].self, from: data)
    }
}
