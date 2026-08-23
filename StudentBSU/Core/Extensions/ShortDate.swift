import Foundation

extension Date {
    private static let shortNoteDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    var toShortNoteString: String {
        return Date.shortNoteDateFormatter.string(from: self)
    }
}
