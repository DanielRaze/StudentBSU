import UIKit

class LoginViewController: UIViewController {
    
    private let buttonGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.appDarkBlue.cgColor, UIColor.appLightBlue.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient
    }()
    
    private let noButtonGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.appDarkBlue.cgColor, UIColor.appLightBlue.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        return gradient
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: .icon)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Студент БГУ"
        label.textColor = .appTextPrimary
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = "Войдите через портал student.bsu.by"
        label.textColor = .appTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [logoImageView, titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var authView = AuthFormView()
    
    private lazy var authButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("ВОЙТИ", for: .normal)
        button.tintColor = .white
        button.layer.insertSublayer(buttonGradient, at: 0)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(authTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var noAuthButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Продолжить без логина", for: .normal)
        button.tintColor = .white
        button.layer.insertSublayer(noButtonGradient, at: 0)
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(noAuthTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var authStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [authView, authButton, noAuthButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            infoStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            authStackView.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 40),
            authStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            authStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            authButton.heightAnchor.constraint(equalToConstant: 50),
            authButton.widthAnchor.constraint(equalTo: authStackView.widthAnchor),
            
            authView.widthAnchor.constraint(equalTo: authStackView.widthAnchor)
        ])
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        
        view.addSubview(infoStackView)
        view.addSubview(authStackView)
        
        authStackView.setCustomSpacing(50, after: authButton)
        
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if buttonGradient.frame.size != authButton.bounds.size {
            buttonGradient.frame = authButton.bounds
        }
        if noButtonGradient.frame.size != noAuthButton.bounds.size {
            noButtonGradient.frame = noAuthButton.bounds
        }
    }
    
    @objc private func authTapped() {
        guard let email = authView.getEmail(), !email.isEmpty,
              let password = authView.getPassword(), !password.isEmpty else {
            let alert = UIAlertController(title: "Ошибка",
                                          message: "Введите данные в поля",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let webAuthVC = AuthWebView(login: email, password: password)
        webAuthVC.delegate = self
        
        let navController = UINavigationController(rootViewController: webAuthVC)
        navController.modalPresentationStyle = .pageSheet
        present(navController, animated: true)
    }
    
    @objc private func noAuthTapped() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return}
        
        UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                window.rootViewController = MainTabBarController()
            }, completion: nil)
    }
}

extension LoginViewController: AuthWebViewControllerDelegate {
    func authDidSuccess(cookies: [HTTPCookie]) {
        
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return}
        
        UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                window.rootViewController = MainTabBarController()
            }, completion: nil)
    }
    
    func authDidFail(error: (any Error)?) {
        let alert = UIAlertController(title: "Ошибка",
                                      message: "\(error?.localizedDescription ?? "")",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

