import UIKit

class AuthFormView: UIView {
    
    private let emailTitle: UILabel = {
        let label = UILabel()
        label.text = "EMAIL"
        label.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .appTextSecondary
        return label
    }()
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "login@student.bsu.by"
        tf.keyboardType = .emailAddress
        tf.textColor = .appTextPrimary
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .appDivider
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let passTitle: UILabel = {
        let label = UILabel()
        label.text = "ПАРОЛЬ"
        label.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .appTextSecondary
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "......."
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textColor = .appTextPrimary
        return tf
    }()
    
    private lazy var eyeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .appTextTertiary
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupActions()
    }
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupActions()
    }
    
    func getEmail() -> String? {
        return emailTextField.text
    }
    
    func getPassword() -> String? {
        return passwordTextField.text
    }
    
    private func setupView() {
        backgroundColor = .appCardBackground
        layer.cornerRadius = 16
        
        passwordTextField.rightView = eyeButton
        passwordTextField.rightViewMode = .always
        
        lazy var emailStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [emailTitle, emailTextField])
            stackView.axis = .vertical
            stackView.spacing = 8
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        lazy var passwordStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [passTitle, passwordTextField])
            stackView.axis = .vertical
            stackView.spacing = 8
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        lazy var mainStackView: UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [emailStackView, separatorView, passwordStackView])
            stackView.axis = .vertical
            stackView.spacing = 16
            stackView.translatesAutoresizingMaskIntoConstraints = false
            return stackView
        }()
        
        addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func setupActions() {
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
    }
}
