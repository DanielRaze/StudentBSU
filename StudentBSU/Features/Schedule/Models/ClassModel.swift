import UIKit

enum ClassType: String, Codable{
    case lecture = "Лекция"
    case practical = "Практика"
    case lab = "Лаб.работа"
    case unknown = "Занятие"
    
    var themeColor: UIColor {
        switch self {
        case .lecture:
            return .appPrimary
        case .practical:
            return .appPurple
        case .lab:
            return .appOrange
        case .unknown:
            return .systemGray
        }
    }
    
    static func from(color: String?, fallbackText: String) -> ClassType {
        if let color = color?.lowercased() {
            if color.contains("fce5cd") || color.contains("252, 229, 205") {
                return .lab
            } else if color.contains("c9daf8") || color.contains("201, 218, 248") {
                return .practical
            } else if color.contains("d9ead3") || color.contains("217, 234, 211") {
                return .lecture
            }
        }
        
        let lower = fallbackText.lowercased()
        if lower.contains("лаб") {
            return .lab
        } else if lower.contains("пг") || lower.contains("ст.пр.") || lower.contains("практ") || lower.contains("пр.") || lower.contains("асс.") || lower.contains("отработка") {
            return .practical
        } else if lower.contains("доц.") || lower.contains("проф.") || lower.contains("лекц") {
            return .lecture
        }
        
        return .lecture
    }
}

struct ClassModel: Codable {
    let name: String
    let startTime: String
    let endTime: String
    let location: String
    let type: ClassType
    let teacher: String
}
