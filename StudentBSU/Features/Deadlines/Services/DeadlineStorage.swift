import Foundation


final class DeadlineStorage {
    static let shared = DeadlineStorage()
    private let activeKey = "saved_active_deadlines"
    private let completedKey = "saved_completed_deadlines"
    
    func saveActive(_ deadlines: [DeadlineModel]) {
        if let data = try? JSONEncoder().encode(deadlines) {
            UserDefaults.standard.set(data, forKey: activeKey)
        }
    }
    
    func saveCompleted(_ deadlines: [DeadlineModel]) {
        if let data = try? JSONEncoder().encode(deadlines) {
            UserDefaults.standard.set(data, forKey: completedKey)
        }
    }
    
    func loadActive() -> [DeadlineModel] {
        guard let data = UserDefaults.standard.data(forKey: activeKey),
              let deadlines = try? JSONDecoder().decode([DeadlineModel].self, from: data) else {
            return []
        }
        return deadlines
    }
    
    func loadCompleted() -> [DeadlineModel] {
        guard let data = UserDefaults.standard.data(forKey: completedKey),
              let deadlines = try? JSONDecoder().decode([DeadlineModel].self, from: data) else {
            return []
        }
        return deadlines
    }
    
}
