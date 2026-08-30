import UIKit

class DeadlineTableCell: UITableViewCell {
    
    var onToggle: (() -> Void)?
    
    
    private lazy var activeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.cornerStyle = .capsule
        let button = UIButton(configuration: config)
        button.layer.borderWidth = 2.0
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(activeTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .appTextPrimary
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var daysBadge: UIButton = {
        
        var config = UIButton.Configuration.tinted()
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        
        let button = UIButton(configuration: config)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var typeStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, daysBadge])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .appTextSecondary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var mainStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [typeStack, infoLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    func configure(with deadline: DeadlineModel, isCompleted: Bool){
        
        daysBadge.isHidden = isCompleted
        
        if isCompleted {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "checkmark.circle.fill")
            activeButton.configuration = config
            activeButton.tintColor = .appGreen
            activeButton.layer.borderWidth = 0
        }
        else {
            var config = UIButton.Configuration.plain()
            config.cornerStyle = .capsule
            activeButton.configuration = config
            activeButton.layer.borderWidth = 2.0
            activeButton.layer.borderColor = deadline.importance.themeColor.cgColor
        }
        
        if isCompleted {
            let attributeString = NSMutableAttributedString(string: deadline.name)
            attributeString.addAttribute(.strikethroughStyle,
                                         value: NSUnderlineStyle.single.rawValue,
                                         range: NSRange(location: 0, length: attributeString.length))
            titleLabel.attributedText = attributeString
            titleLabel.textColor = .appTextSecondary
        } else {
            let attributeString = NSMutableAttributedString(string: deadline.name)
            attributeString.addAttribute(.strikethroughStyle,
                                         value: 0,
                                         range: NSRange(location: 0, length: attributeString.length))
            titleLabel.attributedText = attributeString
            titleLabel.textColor = .appTextPrimary
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date.now, to: deadline.date)
        let days = components.day ?? 0
        
        daysBadge.setTitle("\(days) дн.", for: .normal)
        daysBadge.tintColor = deadline.importance.themeColor
        
        if isCompleted {
            infoLabel.text = deadline.item
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "d MMM"
            let formattedDate = dateFormatter.string(from: deadline.date)
            infoLabel.text = "\(deadline.item) · \(formattedDate)"
        }
    }
    
    @objc private func activeTapped() {
        onToggle?()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            activeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            activeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            activeButton.widthAnchor.constraint(equalToConstant: 28),
            activeButton.heightAnchor.constraint(equalToConstant: 28),
            
            mainStack.leadingAnchor.constraint(equalTo: activeButton.trailingAnchor, constant: 10),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupPriorities() {
        daysBadge.setContentCompressionResistancePriority(.required, for: .horizontal)
        daysBadge.setContentHuggingPriority(.required, for: .horizontal)
        
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .appCardBackground
        contentView.layer.cornerRadius = 16
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        contentView.addSubview(activeButton)
        contentView.addSubview(mainStack)
        
        setupConstraints()
        setupPriorities()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.06
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 6.0
        self.layer.masksToBounds = false
                
        self.layer.shadowPath = UIBezierPath(
                roundedRect: contentView.frame,
                cornerRadius: contentView.layer.cornerRadius
        ).cgPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onToggle = nil
        titleLabel.text = nil
        titleLabel.attributedText = nil
    }
}

