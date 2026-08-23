import UIKit

class NotificationSettingsCardView: UIView {
    
    var onClassesReminderChanged: ((Bool) -> Void)?
    var onExamsReminderChanged: ((Bool) -> Void)?
    var onDeadlinesReminderChanged: ((Bool) -> Void)?
    
    private lazy var classesSwitch = createSwitch(action: #selector(classesSwitchTapped(_:)))
    private lazy var examsSwitch = createSwitch(action: #selector(examsSwitchTapped(_:)))
    private lazy var deadlinesSwitch = createSwitch(action: #selector(deadlinesSwitchTapped(_:)))
    

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .appCardBackground
        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(mainStackView)
        
        setupConstraints()
        setupRows()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
   
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            mainStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])
    }
    
    private func setupRows() {
        let classesRow = createRowView(emoji: "🔔", title: "Напоминания о парах", switchControl: classesSwitch)
        let examsRow = createRowView(emoji: "📅", title: "Напоминания об экзаменах", switchControl: examsSwitch)
        let deadlinesRow = createRowView(emoji: "⏰", title: "Дедлайны", switchControl: deadlinesSwitch)
        
        mainStackView.addArrangedSubview(classesRow)
        mainStackView.addArrangedSubview(createSeparator())
        mainStackView.addArrangedSubview(examsRow)
        mainStackView.addArrangedSubview(createSeparator())
        mainStackView.addArrangedSubview(deadlinesRow)
    }
    
    
    private func createRowView(emoji: String, title: String, switchControl: UISwitch) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.heightAnchor.constraint(equalToConstant: 54).isActive = true
        
        let emojiLabel = UILabel()
        emojiLabel.text = emoji
        emojiLabel.font = UIFont.systemFont(ofSize: 20)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .appTextPrimary
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(emojiLabel)
        container.addSubview(titleLabel)
        container.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: switchControl.leadingAnchor, constant: -12),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            switchControl.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    private func createSwitch(action: Selector) -> UISwitch {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.onTintColor = .appPrimary
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: action, for: .valueChanged)
        return toggle
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = .appDivider
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }
    
    
    @objc private func classesSwitchTapped(_ sender: UISwitch) {
        onClassesReminderChanged?(sender.isOn)
    }
    
    @objc private func examsSwitchTapped(_ sender: UISwitch) {
        onExamsReminderChanged?(sender.isOn)
    }
    
    @objc private func deadlinesSwitchTapped(_ sender: UISwitch) {
        onDeadlinesReminderChanged?(sender.isOn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.06
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 8.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.layer.cornerRadius
        ).cgPath
    }
}

