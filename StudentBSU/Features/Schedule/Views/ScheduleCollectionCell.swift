import UIKit

class ScheduleCollectionCell: UICollectionViewCell {
    
    private lazy var colorIndicator: UIView = {
        let view = UIView()
        view.widthAnchor.constraint(equalToConstant: 4).isActive = true
        view.layer.cornerRadius = 2
        view.backgroundColor = .systemBlue
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .appTextPrimary
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var typeBadge: UIButton = {
        let button = UIButton(configuration: .tinted())
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.configuration?.cornerStyle = .capsule
        button.isUserInteractionEnabled = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var typeStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, typeBadge])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .top
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var timeTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .appPrimary
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var locationTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .appTextSecondary
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [timeTitle, locationTitle])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var teacherLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .appTextTertiary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var mainStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [typeStack, infoStack, teacherLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    func configure(with lesson: ClassModel) {
        var badgeConfig = UIButton.Configuration.tinted()
        badgeConfig.baseBackgroundColor = lesson.type.themeColor
        badgeConfig.baseForegroundColor = lesson.type.themeColor
        
        colorIndicator.backgroundColor = lesson.type.themeColor
        
        badgeConfig.cornerStyle = .capsule
        badgeConfig.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10)
        
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        badgeConfig.attributedTitle = AttributedString(lesson.type.rawValue, attributes: container)
        
        titleLabel.text = lesson.name
        timeTitle.text = "⏰ \(lesson.startTime) - \(lesson.endTime)"
        locationTitle.text = "🏛 ауд. \(lesson.location)"
        teacherLabel.text = lesson.teacher
        
        typeBadge.configuration = badgeConfig
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 14
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .appCardBackground
        
        contentView.addSubview(colorIndicator)
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            colorIndicator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorIndicator.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorIndicator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            mainStack.leadingAnchor.constraint(equalTo: colorIndicator.trailingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
}
