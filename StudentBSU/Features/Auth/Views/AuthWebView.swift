import UIKit
import WebKit

protocol AuthWebViewControllerDelegate: AnyObject {
    func authDidSuccess (cookies: [HTTPCookie])
    func authDidFail(error: Error?)
}

class AuthWebView: UIViewController {
    
    weak var delegate: AuthWebViewControllerDelegate?
    
    private var login: String?
    private var password: String?
    
    private let authWebView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    init(login: String, password: String){
        self.login = login
        self.password = password
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            authWebView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            authWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            authWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            authWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(authWebView)
        
        authWebView.navigationDelegate = self
        
        setupConstraints()
        
        if let url = AppConfig.API.loginURL {
            let request = URLRequest(url: url)
            authWebView.load(request)
        }
    }
}

extension AuthWebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Ошибка начала загрузки страницы: \(error.localizedDescription)")
        delegate?.authDidFail(error: error)
    }
    // Вызывается, если ошибка произошла в процессе загрузки страницы
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Ошибка загрузки страницы: \(error.localizedDescription)")
        delegate?.authDidFail(error: error)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let login = self.login,
                let password = self.password else { return }
        
        let encoder = JSONEncoder()
            guard let safeLoginData = try? encoder.encode(login),
                  let safeLogin = String(data: safeLoginData, encoding: .utf8),
                  let safePasswordData = try? encoder.encode(password),
                  let safePassword = String(data: safePasswordData, encoding: .utf8) else {
                return
            }
        
        let jsScript = """
    (function() {
            var loginField = document.getElementById('ctl00_ContentPlaceHolder0_txtUserLogin');
            var passwordField = document.getElementById('ctl00_ContentPlaceHolder0_txtUserPassword');
 
            if (loginField) {
                loginField.value = \(safeLogin);
                loginField.dispatchEvent(new Event('input', { bubbles: true }));
                loginField.dispatchEvent(new Event('change', {bubbles: true }));
            }
            
            if (passwordField) {
                 passwordField.value = \(safePassword);
                 passwordField.dispatchEvent(new Event('input', { bubbles: true }));
                 passwordField.dispatchEvent(new Event('change', {bubbles: true }));
            }
    })();
 """
        
        webView.evaluateJavaScript(jsScript) { [weak self] (_, error) in
            if let error = error {
                print("Ошибка вставки логина или пароля: \(error)")
            }
            else{
                self?.login = nil
                self?.password = nil
            }
            
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void)
    {
        if let currentURL = navigationAction.request.url?.absoluteString {
            
            if currentURL.contains("PersonalCabinet") {
                extractCookies(from: authWebView)
                decisionHandler(.cancel)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    private func extractCookies(from webView: WKWebView){
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        
        cookieStore.getAllCookies({ [weak self] cookies in
            guard let self = self else { return }
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
            }
            
            self.delegate?.authDidSuccess(cookies: cookies)
            self.dismiss(animated: true)
            
        })
    }
    
}
