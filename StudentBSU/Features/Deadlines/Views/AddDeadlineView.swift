import UIKit


class AddDeadlineView: UIViewController {
    
    var onDeadlineAdded: ((DeadlineModel) -> Void)?
    
    private(set) var selectedPriority: ImportanceType? = nil {
        didSet {
            updatePriorityButtonsAppearance()
        }
    }
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.minimumDate = Date()
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private let titleTextField = UITextField()
    private let subjectTextField = UITextField()
    private let dateTextField = UITextField()
    
    private var priorityButtons: [ImportanceType: UIButton] = [:]
    
    //MARK: Header
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.setTitleColor(.appTextSecondary, for: .normal)
        button.addAction(UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            }, for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новый дедлайн"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var headerStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [cancelButton, titleLabel, addButton] )
        stack.axis = .horizontal
        stack.distribution = .equalCentering
        stack.alignment = .center
        return stack
    }()
    
    private lazy var formContainer = createFormContainer()
    
    private lazy var priorityContainer = createPriorityContainer()
   
    
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [headerStack, formContainer, priorityContainer])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private func createDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = .appDivider
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return divider
    }
    
    private func createDateRow(title: String, picker: UIDatePicker) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .appTextSecondary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, picker])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }
    private func createInputRow(title: String, placeholder: String?, field: UITextField) -> UIStackView {
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 11)
        titleLabel.textColor = .appTextSecondary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if let placeholder = placeholder {
            field.placeholder = placeholder
        }
        field.font = .systemFont(ofSize: 11)
        field.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, field])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }
    
    private func createPriorityButton(title: String, dotColor: UIColor, isSelected: Bool, priority: ImportanceType) -> UIButton {
        var config = UIButton.Configuration.plain()
        var textContainer = AttributeContainer()
        textContainer.font = .systemFont(ofSize: 13, weight: isSelected ? .bold : .medium)
        config.attributedTitle = AttributedString(title, attributes: textContainer)
        config.baseForegroundColor = isSelected ? dotColor : .appTextSecondary
        config.baseBackgroundColor = isSelected ? dotColor.withAlphaComponent(0.1) : .clear
        
        let button = UIButton(configuration: config)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = isSelected ? dotColor.cgColor : UIColor.systemGray.cgColor
        
        button.addAction(UIAction { [weak self] _ in
            self?.selectedPriority = priority
        }, for: .touchUpInside)
        priorityButtons[priority] = button
        
        button.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        return button
    }
    
    private func createPriorityContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .appSecondaryBackground
        container.layer.cornerRadius = 12
        container.clipsToBounds = true
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        container.addSubview(stack)
        
        let title = UILabel()
        title.text = "ПРИОРИТЕТ"
        title.font = .systemFont(ofSize: 12)
        title.textColor = .appTextSecondary
        
        
        let lowButton = createPriorityButton(title: "🔴 Высокий", dotColor: .appRed, isSelected: false, priority: .high)
        let mediumButton = createPriorityButton(title: "🟡 Средний", dotColor: .systemYellow, isSelected: true, priority: .medium)
        let highButton = createPriorityButton(title: "🟢 Низкий", dotColor: .appGreen, isSelected: false, priority: .low)
        
        
        let buttonStack = UIStackView(arrangedSubviews: [lowButton, mediumButton, highButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        buttonStack.alignment = .center
        buttonStack.distribution = .fillEqually
        
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(buttonStack)
        
        container.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
        
    }
    
    private func createFormContainer() -> UIView {
        let container = UIView()
        container.backgroundColor = .appSecondaryBackground
        container.layer.cornerRadius = 12
        container.clipsToBounds = true
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        stack.addArrangedSubview(createInputRow(title: "НАЗВАНИЕ ЗАДАЧИ", placeholder: "Например: Курсовая работа", field: titleTextField))
        stack.addArrangedSubview(createDivider())
        stack.addArrangedSubview(createInputRow(title: "ПРЕДМЕТ", placeholder: "Математика, физика...", field: subjectTextField))
        stack.addArrangedSubview(createDivider())
        stack.addArrangedSubview(createDateRow(title: "ДАТА", picker: datePicker))
        
        return container
    }
    
    private func updatePriorityButtonsAppearance() {
        for (priority, button) in priorityButtons {
            let isSelected = (priority == selectedPriority)
            
            UIView.animate(withDuration: 0.2) {
                if isSelected {
                    button.backgroundColor = priority.themeColor
                    button.setTitleColor(.white, for: .normal)
                    button.layer.borderColor = priority.themeColor.cgColor
                }
                else {
                    button.backgroundColor = .clear
                    button.setTitleColor(.appTextSecondary, for: .normal)
                    button.layer.borderColor = UIColor.systemGray.cgColor
                }
            }
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 32),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupSheetPresentation() {
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 24
        }
    }
    
    @objc private func addButtonTapped() {
        guard let title = titleTextField.text, !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            let alert = UIAlertController(title: "Введите название дедлайна",
                                          message: "",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let subject = subjectTextField.text ?? ""
        let date = datePicker.date
        let priority = selectedPriority ?? .medium
        
        let newDeadline = DeadlineModel(name: title, importance: priority, item: subject, date: date)
        
        onDeadlineAdded?(newDeadline)
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        view.addSubview(mainStackView)
        
        setupConstraints()
        setupSheetPresentation()
        
        
    }
}
