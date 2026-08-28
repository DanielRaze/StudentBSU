import UIKit

class ActionCardView: UIView {
    
    var onToggle: (() -> Void)?
    
    private let authBadge: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 28
        imageView.backgroundColor = .appSecondaryBackground
        imageView.tintColor = .appTextPrimary
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .appTextPrimary
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .appTextSecondary
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .appTextTertiary
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, detailLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var authButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Войти"
        config.cornerStyle = .medium
        
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        container.backgroundColor = .appPrimary
        container.foregroundColor = .white
        
        config.attributedTitle = AttributedString("Войти", attributes: container)
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mainStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [authBadge, infoStack, authButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            authBadge.widthAnchor.constraint(equalToConstant: 56),
            authBadge.heightAnchor.constraint(equalToConstant: 56),
            
            authButton.heightAnchor.constraint(equalToConstant: 38)
        ])
        
        authButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        authButton.setContentHuggingPriority(.required, for: .horizontal)
        infoStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    func configure(
        icon: UIImage?,
        iconBackgroundColor: UIColor = .appSecondaryBackground,
        title: String,
        subtitle: String,
        detailText: String? = nil,
        buttonTitle: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        authBadge.contentMode = .center
        authBadge.image = icon
        authBadge.backgroundColor = iconBackgroundColor
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        if let detail = detailText, !detail.isEmpty {
            detailLabel.text = detail
            detailLabel.isHidden = false
        } else {
            detailLabel.isHidden = true
        }
        
        if let buttonTitle = buttonTitle, !buttonTitle.isEmpty {
            var config = authButton.configuration
            var container = AttributeContainer()
            container.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            config?.attributedTitle = AttributedString(buttonTitle, attributes: container)
            authButton.configuration = config
            authButton.isHidden = false
        } else {
            authButton.isHidden = true
        }
        
        onToggle = onAction
    }
    
    func setAvatarImage(image: UIImage) {
        authBadge.contentMode = .scaleAspectFill
        authBadge.image = image
        authBadge.backgroundColor = .clear
    }
    
    @objc private func buttonTapped() {
        onToggle?()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .appCardBackground
        self.layer.cornerRadius = 16
        self.addSubview(mainStack)
        
        setupConstraints()
    }
    
    required init(coder: NSCoder) {
        fatalError("Not implemented")
    }
}
