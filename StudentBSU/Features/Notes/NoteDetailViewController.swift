import UIKit

class NoteDetailViewController: UIViewController {
    private var note: Note
    
    private var saveTimer: Timer?
    
    private var isDeleted = false
    
    var onDelete: (() -> Void)?
    
    private lazy var deleteButton = UIBarButtonItem(
            image: UIImage(systemName: "trash.fill")?
                .withTintColor(.appRed, renderingMode: .alwaysOriginal),
            style: .prominent,
            target: self,
            action: #selector(deleteTapped)
        )
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .appTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tagTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 13, weight: .bold)
        textField.textColor = .appTextPrimary
        
        textField.borderStyle = .none
        textField.backgroundColor = UIColor.appTextPrimary.withAlphaComponent(0.08)
        textField.layer.cornerRadius = 8
        textField.clipsToBounds = true
        
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.leftView = leftPadding
        textField.leftViewMode = .always
        
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        textField.rightView = rightPadding
        textField.rightViewMode = .always
        
        textField.attributedPlaceholder = NSAttributedString(
            string: "Введите предмет...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.appTextPrimary.withAlphaComponent(0.4)]
        )
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var dateTagStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dateLabel, tagTextField])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 24, weight: .bold)
        textField.textColor = .appTextPrimary
        textField.placeholder = "Введите заголовок..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var bodyTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .appTextSecondary
        textView.isEditable = true
        textView.backgroundColor = .clear
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dateTagStack, titleTextField, bodyTextView])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    
    
    init(note: Note) {
        self.note = note
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tagTextField.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func saveNote(){
        note.title = titleTextField.text
        note.text = bodyTextView.text
        note.tag = tagTextField.text
        
        NoteDataManager.shared.saveNote(note)
    }
    
    @objc private func deleteTapped() {
        let alert = UIAlertController(title: "Удалить заметку?",
                                      message: "Это действие нельзя будет отменить!",
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.isDeleted = true
            NoteDataManager.shared.deleteNote(self.note)
            
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mainStack)
        
        bodyTextView.delegate = self
        
        view.backgroundColor = note.backgroundColor
        titleTextField.text = note.title
        tagTextField.text = note.tag
        bodyTextView.text = note.text
        dateLabel.text = note.date.toShortNoteString
        
        navigationItem.rightBarButtonItem = deleteButton
        
        setupConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = note.backgroundColor
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveTimer?.invalidate()
        if !isDeleted {
            saveNote()
        }
    }
    
}

extension NoteDetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        saveTimer?.invalidate()
        
        saveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.saveNote()
        }
    }
}

extension NoteDetailViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveTimer?.invalidate()
        Task { [weak self] in
            self?.saveNote()
        }
    }
}
