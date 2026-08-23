import Foundation

enum AppConfig {
    
    enum API {
        static let baseURL = "https://student.bsu.by"
    
        static let loginURL = URL(string: "\(baseURL)/login")
        
        static let studProgressURL = URL(string: "\(baseURL)/PersonalCabinet/StudProgress")
        
        static let dormitoryURL = URL(string: "\(baseURL)/PersonalCabinet/Hostel")!
    }
    
}
