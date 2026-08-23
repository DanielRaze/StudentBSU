import UIKit

class ScheduleService {
    
    static let shared = ScheduleService()
    
    func fetchLessons(group: String, course: Course) async throws -> (schedule: [Int: [ClassModel]], startDate: Date?) {
        guard let rawUrlString = FirebaseManager.shared.getScheduleURL(forCourse: course.rawValue) else {
            print("Неверная ссылка для курса \(course.title)")
            throw URLError(.badURL)
        }
        let cleanUrlString = rawUrlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanUrlString.isEmpty, let url = URL(string: cleanUrlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let csvText = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        let schedule = parseScheduleCSV(csvText, targetGroup: group)
        var startDate: Date? = nil
        
        let filename = response.suggestedFilename ?? url.lastPathComponent
        
        let regex = try? NSRegularExpression(pattern: "(\\d{1,2})\\.(\\d{1,2})\\s*[-–—]\\s*\\d{1,2}\\.\\d{1,2}")
        if let match = regex?.firstMatch(in: filename, range: NSRange(filename.startIndex..., in: filename)) {
            if let dayRange = Range(match.range(at: 1), in: filename),
               let monthRange = Range(match.range(at: 2), in: filename) {
                let day = Int(filename[dayRange]) ?? 1
                let month = Int(filename[monthRange]) ?? 1
                
                var components = DateComponents()
                components.day = day
                components.month = month
                components.year = Calendar.current.component(.year, from: Date())
                startDate = Calendar.current.date(from: components)
            }
        }
        
        return (schedule, startDate)
    }
    
    func fetchCurrentStudentSchedule() async throws -> (course: Course, group: String, schedule: [Int: [ClassModel]], startDate: Date?, isOffline: Bool) {
        let savedCourseInt = UserDefaults.standard.integer(forKey: "studentCourseNumber")
        let course = Course(rawValue: savedCourseInt == 0 ? 3 : savedCourseInt) ?? .third
        let savedGroup = UserDefaults.standard.string(forKey: "studentGroupNumber") ?? "7 группа"
        do {
            let result = try await fetchLessons(group: savedGroup, course: course)
            CacheManager.shared.save(result.schedule, to: "schedule.json")
            return (course, savedGroup, result.schedule, result.startDate, false)
        } catch {
            if let cachedSchedule = CacheManager.shared.load([Int: [ClassModel]].self, from: "schedule.json") {
                return (course, savedGroup, cachedSchedule, nil, true)
            } else {
                throw NetworkError.noInternet
            }
        }
        
    }
    
    private func parseScheduleCSV(_ csvText: String, targetGroup: String) -> [Int: [ClassModel]] {
        let rows = parseCSVRows(csvText)
        guard !rows.isEmpty else { return [:] }
        
        let groupDigits = targetGroup.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let searchNumber = groupDigits.isEmpty ? targetGroup.trimmingCharacters(in: .whitespaces) : groupDigits
        
        var groupColIndex: Int? = nil
        var headerRowIndex: Int = 0
        
        for (rIdx, row) in rows.enumerated() {
            for (cIdx, cell) in row.enumerated() {
                let cleanCell = cell.lowercased().replacingOccurrences(of: "\n", with: " ")
                if cleanCell.contains("группа") {
                    let cellNumbers = cleanCell.components(separatedBy: CharacterSet.decimalDigits.inverted).filter { !$0.isEmpty }
                    if cellNumbers.contains(searchNumber) || cleanCell.contains("группа \(searchNumber)") || cleanCell.contains("группа\(searchNumber)") {
                        groupColIndex = cIdx
                        headerRowIndex = rIdx
                        break
                    }
                }
            }
            if groupColIndex != nil { break }
        }
        
        guard let groupCol = groupColIndex else {
            print("Не найдена колонка для группы: \(targetGroup) (цифра: \(searchNumber))")
            return [:]
        }
        
        var scheduleByDay: [Int: [ClassModel]] = [:]
        var currentWeekday: Int = 2
        
        let dayMapping: [String: Int] = [
            "пн": 2, "вт": 3, "ср": 4, "чт": 5, "пт": 6, "сб": 7
        ]
        
        let dataRows = rows.dropFirst(headerRowIndex + 1)
        
        for row in dataRows {
            guard row.count > groupCol else { continue }
            
            let dayText = row.first?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
            for (prefix, wDay) in dayMapping {
                if dayText.contains(prefix) {
                    currentWeekday = wDay
                    break
                }
            }
            
            let rawTime = row.count > 2 ? row[2].replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespaces) : ""
            let (startTime, endTime) = parseTime(rawTime)
            
            let lessonText = row[groupCol].trimmingCharacters(in: .whitespacesAndNewlines)
            let roomText = row.count > groupCol + 1 ? row[groupCol + 1].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: " ") : ""
            
            if !lessonText.isEmpty && lessonText != "-" && !lessonText.lowercased().contains("группа") {
                let classType = ClassType.from(color: nil, fallbackText: lessonText)
                let classModel = parseClassInfo(
                    lessonText: lessonText,
                    location: roomText,
                    startTime: startTime,
                    endTime: endTime,
                    type: classType
                )
                
                if scheduleByDay[currentWeekday] == nil {
                    scheduleByDay[currentWeekday] = []
                }
                scheduleByDay[currentWeekday]?.append(classModel)
            }
        }
        return scheduleByDay
    }
    
    private func parseCSVRows(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentCell = ""
        var insideQuotes = false
        
        for char in text {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                currentRow.append(currentCell)
                currentCell = ""
            } else if char.isNewline && !insideQuotes {
                currentRow.append(currentCell)
                rows.append(currentRow)
                currentRow = []
                currentCell = ""
            } else {
                currentCell.append(char)
            }
        }
        
        if !currentCell.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentCell)
            rows.append(currentRow)
        }
        
        return rows
    }
    
    private func parseTime(_ rawTime: String) -> (start: String, end: String) {
        let parts = rawTime.components(separatedBy: CharacterSet(charactersIn: "-–—\n"))
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let start = parts.first ?? "09:00"
        let end = parts.count > 1 ? parts[1] : "10:25"
        return (start, end)
    }
    
    private func parseClassInfo(lessonText: String, location: String, startTime: String, endTime: String, type: ClassType) -> ClassModel {
        let lines = lessonText.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var subjectLines: [String] = []
        var metaLines: [String] = []
        var teacher = ""
        var foundTeacherOrGroup = false
        
        for line in lines {
            let lower = line.lowercased()
            
            var isMeta = false
            if lower.contains("перенос") || lower.contains("отработка") || lower.contains("замена") || lower.contains("отмена") {
                isMeta = true
            } else if lower.range(of: "^[\\d\\s\\.,с СнаНА]*(ауд\\s*\\d+)?$", options: .regularExpression) != nil && lower.rangeOfCharacter(from: .decimalDigits) != nil {
                isMeta = true
            } else if lower.hasPrefix("с ") && lower.contains(".") {
                isMeta = true
            } else if lower.hasPrefix("на ") && lower.contains(".") {
                isMeta = true
            }
            
            if isMeta {
                metaLines.append(line)
                continue
            }
            
            let isTeacher = lower.contains("доц.") || lower.contains("ст.пр.") || lower.contains("проф.") || lower.contains("асс.") || lower.contains("пр.") || lower.contains(".")
            let isGroup = lower.contains("пг") || lower.contains("подгруппа") || lower.contains("еженедельно") || lower.contains("раз")
            
            if isTeacher || isGroup {
                foundTeacherOrGroup = true
                if teacher.isEmpty && isTeacher {
                    teacher = line
                }
            } else if !foundTeacherOrGroup {
                subjectLines.append(line)
            }
        }
        
        let cleanSubject = subjectLines.isEmpty ? (lines.first ?? lessonText) : subjectLines.joined(separator: " ")
        var finalSubject = cleanSubject
        if !metaLines.isEmpty {
            finalSubject += " (" + metaLines.joined(separator: ", ") + ")"
        }
        
        let cleanLocation = location.isEmpty ? "ДО" : location
        let cleanTeacher = teacher.isEmpty ? (lines.count > 1 ? lines[1] : "Кафедра") : teacher
        
        return ClassModel(
            name: finalSubject,
            startTime: startTime,
            endTime: endTime,
            location: cleanLocation,
            type: type,
            teacher: cleanTeacher
        )
    }
}
