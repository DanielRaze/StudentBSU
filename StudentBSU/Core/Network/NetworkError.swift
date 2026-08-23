import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decodingError(Error)
    case unauthorized
    case noInternet
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный адрес запроса."
        case .invalidResponse:
            return "Некорректный ответ сервера"
        case .statusCode(let code):
            return "Ошибка сервера (код \(code))."
        case .decodingError:
            return "Ошибка обработки данных."
        case .unauthorized:
            return "Требуется авторизация."
        case .noInternet:
            return "Нет интернета!"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
