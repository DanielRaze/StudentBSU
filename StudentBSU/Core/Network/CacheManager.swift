import Foundation

final class CacheManager {
    static let shared = CacheManager()
    
    private var cacheDir: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    func save<T: Codable> (_ object: T, to filename: String) {
        do {
            let data = try JSONEncoder().encode(object)
            let fileURL = cacheDir.appendingPathComponent(filename)
            try data.write(to: fileURL)
        } catch {
            print("Ошибка сохранения кэша: \(error)")
        }
    }
    
    func load <T: Codable> (_ type: T.Type, from filename: String) -> T? {
        let fileURL = cacheDir.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
