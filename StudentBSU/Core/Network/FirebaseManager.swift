import Foundation
import FirebaseRemoteConfig
import FirebaseStorage

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init(){}
    
    var schedule1URL: String?
    var schedule2URL: String?
    var schedule3URL: String?
    var schedule4URL: String?
    
    func fetchRemoteConfig() async {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        do {
            let status = try await remoteConfig.fetch()
            if status == .success {
                try await remoteConfig.activate()
                
            }
        } catch {
            print("Ошибка Remote Config: \(error)")
        }
    }
    
    func getScheduleURL(forCourse course: Int) -> String? {
        let key = "schedule_\(course)_url"
        let urlString = RemoteConfig.remoteConfig().configValue(forKey: key).stringValue
        guard !urlString.isEmpty else { return nil }
        return urlString
    }
    
    func downloadExamsJSON() async throws -> [FirebaseExam] {
        let fileName = "exams.json"
        
        let storage = Storage.storage()
        let localURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            storage.reference().child(fileName).write(toFile: localURL) { url, error in
                if let error = error { continuation.resume(throwing: error)}
                else if let url = url { continuation.resume(returning: url) }
            }
        }
        
        let data = try Data(contentsOf: localURL)
        return try JSONDecoder().decode([FirebaseExam].self, from: data)
    }
}

struct FirebaseExam: Codable {
    let course: Int
    let group: String
    let name: String
    let teacher: String
    let date: String
    let time: String
    let location: String
}
