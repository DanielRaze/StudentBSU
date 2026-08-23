import Foundation

class NetworkManager: NSObject, URLSessionTaskDelegate {
    private lazy var session: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()

    func checkSession (at url: URL) async throws -> Bool {
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = true
        
        let (_, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            return httpResponse.statusCode == 200
        }
        return false
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        if let nextURL = request.url {
            let urlString = nextURL.absoluteString
            
            if(urlString.contains("/login")) {
                print("Сессия недействительна!")
                completionHandler(nil)
                return
            }
            
            if urlString.contains("/PersonalCabinet"){
                
            }
        }
        
        completionHandler(request)
    }
}
