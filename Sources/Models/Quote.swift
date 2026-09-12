import Foundation

public struct Quote: Identifiable, Codable, Hashable {
    public let id: String
    public let text: String
    public let author: String?
    public let category: String?
    
    public init(id: String = UUID().uuidString, text: String, author: String? = nil, category: String? = nil) {
        self.id = id
        self.text = text
        self.author = author
        self.category = category
    }
}
