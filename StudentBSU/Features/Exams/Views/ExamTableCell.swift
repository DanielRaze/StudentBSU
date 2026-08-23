import UIKit

class ExamTableCell: UITableViewCell {
    
    private let calendar = Calendar.current
    private let formatter = DateFormatter()
    
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .appCardBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var dateBadge: DateBadgeView = DateBadgeView()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .appTextPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .appTextSecondary
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
    
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .appTextTertiary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var verticalStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, infoLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var mainStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dateBadge, verticalStack, daysBadge])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            daysBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 32),
            daysBadge.heightAnchor.constraint(equalToConstant: 24),
        ])
    }
    
    private func setupPriorities() {
        verticalStack.setContentHuggingPriority(.defaultLow, for: .horizontal)
        daysBadge.setContentCompressionResistancePriority(.required, for: .horizontal)
        daysBadge.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func configure(from exam: ExamModel, isCompleted: Bool){
        let isMissingData = (exam.time == "Уточняется" || exam.location == "Уточняется" || exam.time == "No time")
        
        if isMissingData {
            dateBadge.isHidden = true
            subtitleLabel.isHidden = true
            infoLabel.isHidden = true
        } else {
            dateBadge.isHidden = false
            subtitleLabel.isHidden = false
            infoLabel.isHidden = false
        }
        
        switch isCompleted {
        case true:
            dateBadge.backgroundColor = .appGreen
        case false:
            dateBadge.backgroundColor = exam.themeColor
        }
        
        let components = calendar.dateComponents([.day, .month, .weekday], from: exam.date)
        let daysLeftComponents = calendar.dateComponents([.day], from: Date(), to: exam.date)
        
        let days = components.day ?? 0
        formatter.dateFormat = "MMM"
        let shortMonthText = formatter.string(from: exam.date)
        formatter.dateFormat = "EEEE"
        let shortDayText = formatter.string(from: exam.date)
        
        dateBadge.setDay(day: days)
        dateBadge.setMonth(month: shortMonthText)
        
        titleLabel.text = exam.name
        subtitleLabel.text = "\(shortDayText) · \(exam.time)"
        
        let daysLeft = daysLeftComponents.day ?? 0
        
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8)
    
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 12, weight: .bold)

        if isCompleted {
            daysBadge.isHidden = false
            config.baseBackgroundColor = .appSecondaryBackground
            config.baseForegroundColor = .appTextSecondary
            
            if let mark = exam.mark {
                config.baseBackgroundColor = .appSecondaryBackground
                config.baseForegroundColor = .appGreen
                        
                var markContainer = AttributeContainer()
                markContainer.font = UIFont.systemFont(ofSize: 14, weight: .bold)
                        
                config.attributedTitle = AttributedString("\(mark)", attributes: markContainer)
                config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
                config.image = nil
            } else {
                daysBadge.isHidden = true
            }
        } else {
            if isMissingData {
                daysBadge.isHidden = true
            } else {
                daysBadge.isHidden = false
                config.baseBackgroundColor = exam.themeColor.withAlphaComponent(0.15)
                config.baseForegroundColor = exam.themeColor                        
                
                container.foregroundColor = exam.themeColor
                config.attributedTitle = AttributedString("\(daysLeft) дн", attributes: container)
                config.image = nil
            }
        }

        daysBadge.configuration = config
        
        infoLabel.text = "ауд. \(exam.location) · \(exam.teacher)"
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        contentView.backgroundColor = .clear
        
        contentView.addSubview(cardView)
        cardView.addSubview(mainStack)
        
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        setupConstraints()
        setupPriorities()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.06
        cardView.layer.shadowOffset = CGSize(width: 0, height: 3)
        cardView.layer.shadowRadius = 6.0
        cardView.layer.masksToBounds = false
        
        self.layer.shadowPath = UIBezierPath(
            roundedRect: cardView.bounds,
            cornerRadius: cardView.layer.cornerRadius
        ).cgPath
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        titleLabel.attributedText = nil
        daysBadge.configuration = nil
    }
}

