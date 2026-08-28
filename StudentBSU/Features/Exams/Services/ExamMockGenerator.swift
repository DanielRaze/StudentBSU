import UIKit
import WebKit
import SwiftSoup
import RegexBuilder

final class ExamMockGenerator {
    
    private func createDate(daysFromNow: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: daysFromNow, to: Date()) ?? Date()
    }
    
    static let shared = ExamMockGenerator()
    
    
    func getExams(for sem: Int) async throws -> (exams: [ExamModel], isOffline: Bool) {
        do {
            guard let url = AppConfig.API.studProgressURL else {
                throw NetworkError.invalidURL
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let html = String(data: data, encoding: .utf8) else { throw NetworkError.invalidResponse }
            
            let document = try SwiftSoup.parse(html)
            let (viewState, viewStateGen, eventValidation) = try getHiddenAttributes(document: document)
            let sessionLinks: [SessionLinkModel] = try getSessionLinksData(document: document)
            
            
            guard let currentSem = sessionLinks.first(where: { $0.target?.contains("Semester\(sem)") == true }) else {
                print("Не найдена ссылка для семестра \(sem). (Искали Semester\(sem))")
                throw NetworkError.statusCode(100)
            }
            
            var parameters: [String: String] = [
                "__EVENTTARGET": currentSem.target ?? "",
                "__EVENTARGUMENT": "",
                "__VIEWSTATE": viewState
            ]
            
            if !viewStateGen.isEmpty {
                parameters["__VIEWSTATEGENERATOR"] = viewStateGen
            }
            if !eventValidation.isEmpty {
                parameters["__EVENTVALIDATION"] = eventValidation
            }
            var exams = try await parseExam(with: parameters, currentSem: currentSem, url: url)
            
            let currentSemester = calculateCurrentSemester()
            
            if sem == currentSemester {
                let course = UserDefaults.standard.integer(forKey: "studentCourseNumber")
                let safeCourse = course > 0 ? course : 1
                
                let rawGroup = UserDefaults.standard.string(forKey: "studentGroupNumber") ?? "7"
                let groupString = rawGroup.components(separatedBy: CharacterSet(charactersIn: "0123456789.").inverted).joined()
                
                
                do {
                    let allExams = try await FirebaseManager.shared.downloadExamsJSON()
                    
                    let firebaseExams = allExams.filter {
                        guard $0.course == safeCourse else { return false }
                        let parts = $0.group.components(separatedBy: "+").map {
                            $0.trimmingCharacters(in: .whitespaces)}
                        return parts.contains(groupString) || $0.group == groupString
                    }
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    for i in 0..<exams.count {
                        let portalName = exams[i].name.lowercased().components(separatedBy: CharacterSet.letters.inverted).joined()
                        if let match = firebaseExams.first(where: {
                            let jsonName = $0.name.lowercased().components(separatedBy: CharacterSet.letters.inverted).joined()
                            return portalName.contains(jsonName) || jsonName.contains(portalName)
                        }) {
                            exams[i].time = match.time
                            exams[i].location = match.location
                            exams[i].teacher = match.teacher
                            if let realDate = dateFormatter.date(from: match.date) {
                                exams[i].date = realDate
                            }
                        } else {
                            exams[i].time = "No time"
                            exams[i].location = "Уточняется"
                        }
                    }
                } catch {
                    print("Файл с расписанием в Firebase еще не загружен или ошибка: \(error)")
                }
            }
            CacheManager.shared.save(exams, to: "exams_cache_\(sem).json")
            return (exams, false)
        } catch {
            if let cachedExams = CacheManager.shared.load([ExamModel].self, from: "exams_cache_\(sem).json") {
                return (cachedExams, true)
            }
            
            throw NetworkError.noInternet
        }
        
    }
    
    func calculateCurrentSemester() -> Int {
        let course = UserDefaults.standard.integer(forKey: "studentCourseNumber")
        let safeCourse = course > 0 ? course : 1
        
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        let autumnSessionMonths = [8, 9, 10, 11, 12, 1, 2]
        
        let isAutumnSession = autumnSessionMonths.contains(currentMonth)
        
        if isAutumnSession {
            return safeCourse * 2 - 1
        } else {
            return safeCourse * 2     
        }
    }
    
    private func parseExam(with parameters: [String: String], currentSem: SessionLinkModel, url: URL) async throws -> [ExamModel] {
        let bodyString = parameters
            .map { "\($0.key)=\(urlEncode($0.value))" }
            .joined(separator: "&")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"


        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyString.data(using: .utf8)
        let (data, _) = try await URLSession.shared.data(for: request)
        guard let html = String(data: data, encoding: .utf8) else { throw NetworkError.invalidResponse }
        
        let document = try SwiftSoup.parse(html)
        let table = try
        document.getElementById("ctl00_ctl00_ContentPlaceHolder0_ContentPlaceHolder1_ctlStudProgress1_tblProgress")
        guard let table = table else { 
            print("Таблица с оценками не найдена на странице после POST-запроса!")
            throw NetworkError.invalidResponse
        }
        let rows = try table.select("tr")
        
        var exams: [ExamModel] = []
        
        for (index, row) in rows.enumerated() {
            if index < 2 { continue }
            let columns = try row.select("td")
            
            if columns.count >= 10 {
                let subjectName = try columns[1].text()
                let testGrade = try columns[8].text()
                let examGrade = try columns[9].text()
                var allGrade: Int? = nil
                var examType: ExamType
                let cleanTest = testGrade.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let cleanExam = examGrade.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if let grade = Int(cleanTest) {
                    allGrade = grade
                    examType = .test
                } else if cleanTest.contains("зачет") {
                    examType = .test
                }

                else if let grade = Int(cleanExam) {
                    allGrade = grade
                    examType = .exam
                } else if cleanExam.contains("экзамен") {
                    examType = .exam
                }
                else {
                    continue
                }

                let exam = ExamModel(
                    name: subjectName, 
                    time: "Уточняется", 
                    date: Date(), 
                    location: "Уточняется", 
                    teacher: "Неизвестен", 
                    mark: allGrade, 
                    type: examType
                )
                exams.append(exam)
            } else {
            }
            
        }
        
        return exams
        
    }
    
    
    private func urlEncode(_ string: String) -> String {
        var allowedCharacters = CharacterSet.urlQueryAllowed
        allowedCharacters.remove(charactersIn: "+=/&")
        
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? string
    }
    
    
    private func getSessionLinksData(document: Document) throws -> [SessionLinkModel] {
        let sessionLinks: Elements = try document.select("a:contains(сессия)")
        var sessionModels: [SessionLinkModel] = []
        for link in sessionLinks.array() {
            let text = try link.text()
            let href = try link.attr("href")
            let id = try link.attr("id")
            sessionModels.append(SessionLinkModel(text: text, href: href, id: id))
        }
        
        let regex = Regex {
            "'"
            Capture {
                "ctl00"
                ZeroOrMore {
                    CharacterClass.anyOf("'").inverted
                }
            }
            "'"
        }
        for index in sessionLinks.indices {
            if let match = sessionModels[index].href?.firstMatch(of: regex){
                let target = String(match.output.1)
                sessionModels[index].target = target
            }
        }
        return sessionModels
    }
    
    private func getHiddenAttributes(document: Document) throws -> (viewState: String, viewStateGen: String, eventValidation: String) {
        let viewState = (try? document.select("input[name=__VIEWSTATE]").first()?.attr("value")) ?? ""
        let viewStateGen = (try? document.select("input[name=__VIEWSTATEGENERATOR]").first()?.attr("value")) ?? ""
        let eventValidation = (try? document.select("input[name=__EVENTVALIDATION]").first()?.attr("value")) ?? ""
        
        return (viewState, viewStateGen, eventValidation)
    }
}
