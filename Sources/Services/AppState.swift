import Foundation
import Combine

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isZenModeActive = false
    @Published var hideTabBar = false
}
