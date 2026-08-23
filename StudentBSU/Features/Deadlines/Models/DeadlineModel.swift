import UIKit

enum ImportanceType: String, Codable {
    case low
    case medium
    case high
    
    var themeColor: UIColor {
        switch self {
        case .low:
            return .appGreen
        case .medium:
            return .appOrange
        case .high:
            return .appRed
        }
    }
}


struct DeadlineModel: Codable {
    var name: String
    var importance: ImportanceType
    var item: String
    var date: Date
}
