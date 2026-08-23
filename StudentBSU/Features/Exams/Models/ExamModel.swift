import UIKit

enum ExamType: String, Codable {
    case exam = "Exam"
    case test = "Test"
}


struct ExamModel: Codable {
    let name: String
    var time: String
    var date: Date
    var location: String
    var teacher: String
    let mark: Int?
    let type: ExamType
    var passed: Bool {
        if mark != nil {
            return true
        }
        else {
            return false
        }
    }
    var themeColor: UIColor {
        let calendar = Calendar.current
        
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfExamDay = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfExamDay)
        let daysLeft = components.day ?? 0
        
        switch daysLeft {
        case ...0:
            return .appTextTertiary
        case 1...3:
            return .appRed
        case 4...7:
            return .appOrange
        default:
            return .appGreen
        }
    }
}
