import Foundation

class SupabaseService {
    static let shared = SupabaseService()
    
    // UserDefaults keys for connection details
    private let urlKey = "supabase_url"
    private let anonKeyKey = "supabase_anon_key"
    
    var isConfigured: Bool {
        return getUrl() != nil && getAnonKey() != nil
    }
    
    func getUrl() -> String? {
        UserDefaults.standard.string(forKey: urlKey)
    }
    
    func getAnonKey() -> String? {
        UserDefaults.standard.string(forKey: anonKeyKey)
    }
    
    func saveCredentials(url: String, anonKey: String) {
        let cleanUrl = url.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        UserDefaults.standard.set(cleanUrl, forKey: urlKey)
        UserDefaults.standard.set(anonKey.trimmingCharacters(in: .whitespacesAndNewlines), forKey: anonKeyKey)
    }
    
    func fetchQuotes() async throws -> [Quote] {
        guard let baseUrlString = getUrl(), let anonKey = getAnonKey() else {
            throw NSError(domain: "SupabaseService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Supabase is not configured in Settings."])
        }
        
        guard let url = URL(string: "\(baseUrlString)/rest/v1/quotes?select=*") else {
            throw NSError(domain: "SupabaseService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid Supabase URL."])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "SupabaseService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response from server."])
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "SupabaseService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned error: \(httpResponse.statusCode). Ensure your table is named 'quotes' and has public read access."])
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode([Quote].self, from: data)
    }
}
