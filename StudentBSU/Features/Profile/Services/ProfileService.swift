import Foundation
import UIKit
import SwiftSoup


protocol ProfileServiceProtocol {
    func fetchProfileData() async throws -> StudentProfileModel
    func fetchDormitoryStatus() async -> (isProvided: Bool, roomInfo: String?)
}

final class ProfileService: ProfileServiceProtocol {
    
    func fetchDormitoryStatus() async -> (isProvided: Bool, roomInfo: String?) {
        do{
            let (data, _) = try await URLSession.shared.data(from: AppConfig.API.dormitoryURL)
            guard let html = String(data: data, encoding: .utf8) else { return (false, nil) }
            
            let document = try SwiftSoup.parse(html)
            
            guard let label = try document.getElementById("ctl00_ctl00_ContentPlaceHolder0_ContentPlaceHolder1_lbHouse2") else {
                    return (false, nil)
                }
            let labelText = try label.text()
            
            return (true, labelText)
        } catch {
            print("Ошибка парсинга: \(error)")
            return (false, nil)
        }
    }
    
    func fetchProfileData() async throws -> StudentProfileModel {
        guard let url = AppConfig.API.studProgressURL else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw NetworkError.invalidResponse
        }
        let doc = try SwiftSoup.parse(html)
        guard let fio = try doc.getElementById("ctl00_ctl00_ContentPlaceHolder0_lbFIO1")?.text(), !fio.isEmpty else {
                    throw NetworkError.unauthorized
                }
        return try parseProfile(from: doc)
    }
    
    private func parseProfile(from doc: Document) throws -> StudentProfileModel {
        guard let fio = try doc.getElementById("ctl00_ctl00_ContentPlaceHolder0_lbFIO1")?.text(), !fio.isEmpty else {
                    throw NetworkError.unauthorized
                }
        let faculty = try doc.getElementById("ctl00_ctl00_ContentPlaceHolder0_ContentPlaceHolder1_ctlStudProgress1_lbStudFacultet")?.text() ?? "БГУ"
        let rawCourseInfo = try doc.getElementById("ctl00_ctl00_ContentPlaceHolder0_ContentPlaceHolder1_ctlStudProgress1_lbStudKurs")?.text() ?? ""
        let formattedInfo = formatCourseInfo(rawCourseInfo)
        
        var photoURL: URL? = nil
        
        if let photoPath = try doc.getElementById("ctl00_ctl00_imgStudPhoto")?.attr("src") {
            let cleanPath = photoPath.replacingOccurrences(of: "../", with: "")
            photoURL = URL(string: "\(AppConfig.API.baseURL)/\(cleanPath)")
        }
        
        let courseNumber = Int(formattedInfo.course.filter {$0.isNumber} ) ?? 3
        UserDefaults.standard.set(courseNumber, forKey: "studentCourseNumber")
        UserDefaults.standard.set(formattedInfo.group, forKey: "studentGroupNumber")
        
        return StudentProfileModel(fullName: fio,
                                   faculty: faculty,
                                   course: formattedInfo.course,
                                   group: formattedInfo.group,
                                   specialization: formattedInfo.specialization,
                                   photoURL: photoURL)
    }
    
    private func formatCourseInfo(_ raw: String) -> (course: String, group: String, specialization: String) {
        let components = raw.components(separatedBy: ",")
        
        var course: String = "3 курс"
        var group: String = "7 группа"
        var spec: String = "ФПМИ"
        
        for part in components {
            let trimmed = part.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("курс") { course = trimmed }
            else if trimmed.contains("группа") { group = trimmed }
            else if trimmed.contains("специальность:") {
                spec = trimmed.replacingOccurrences(of: "специальность:",
                                                    with: "").trimmingCharacters(in: .whitespaces).capitalized
            }
        }
        return ("\(course)", "\(group)", spec)
    }
}
