import UIKit

class SplashViewController: UIViewController {
    
    private let networkManager = NetworkManager()
    
    private lazy var gradientView: CAGradientLayer = {
        let gradient = CAGradientLayer()
        let topColor = UIColor.appDarkBlue.cgColor
        let bottomColor = UIColor.appLightBlue.cgColor
        gradient.colors = [topColor, bottomColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = view.bounds
        return gradient
    }()
    private lazy var logoImageView = UIImageView(image: .icon)
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Student Helper"
        label.textColor = .white
        return label
    }()
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = "БЕЛАРУСКI ДЗЯРЖАЎНЫ ЎНIВЕРСIТЭТ"
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let loadingIndicator: CustomSpinnerView = {
        let spinnerView = CustomSpinnerView()
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        return spinnerView
    }()
    
    
    private lazy var splashStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [logoImageView, titleLabel, subtitleLabel, loadingIndicator])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            splashStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
        ])
    }
    
    private func checkLogin() async throws {
        guard let url = URL(string: "https://student.bsu.by/PersonalCabinet") else {
            return
        }
        
        let isValidSession = try await networkManager.checkSession(at: url)
        
        if isValidSession {
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        } else {
            print("Редирект был заблокирован или сессия истекла!")
            UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        }
    }
    
    private func navigateToLogin() {
        Task {
            do{
                try await checkLogin()
            }
            catch {
                print("Ошибка сети: \(error)")
            }
            let isLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
            await FirebaseManager.shared.fetchRemoteConfig()
            
            await MainActor.run {
                switch isLoggedIn {
                case true:
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let window = windowScene.windows.first else { return}
                    
                    UIView.transition(with: window,
                                          duration: 0.3,
                                          options: .transitionCrossDissolve,
                                          animations: {
                            window.rootViewController = MainTabBarController()
                        }, completion: nil)
                case false:
                    let nextVC = LoginViewController()
                    let navigationController = UINavigationController(rootViewController: nextVC)
                    
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                          let window = windowScene.windows.first else { return}
                    
                    UIView.transition(with: window,
                                          duration: 0.3,
                                          options: .transitionCrossDissolve,
                                          animations: {
                            window.rootViewController = navigationController
                        }, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(splashStackView)
        splashStackView.setCustomSpacing(100, after: subtitleLabel)
        setupConstraints()
        view.layer.insertSublayer(gradientView, at: 0)
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadingIndicator.startAnimating()
        self.navigateToLogin()
    }
}
