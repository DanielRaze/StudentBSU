import UIKit

class NoteCardCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .appTextPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .appTextSecondary
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .appTextPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tagContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .appCardBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tagLabel)
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .appTextSecondary
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bottomStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [tagContainerView, dateLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var mainStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel, bottomStack])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tagLabel.topAnchor.constraint(equalTo: tagContainerView.topAnchor, constant: 6),
            tagLabel.bottomAnchor.constraint(equalTo: tagContainerView.bottomAnchor, constant: -6),
            tagLabel.leadingAnchor.constraint(equalTo: tagContainerView.leadingAnchor, constant: 12),
            tagLabel.trailingAnchor.constraint(equalTo: tagContainerView.trailingAnchor, constant: -12),
            
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with note: Note) {
        titleLabel.text = note.title
        bodyLabel.text = note.text
        dateLabel.text = note.date.toShortNoteString
        contentView.backgroundColor = note.backgroundColor
        
        if let tag = note.tag {
            tagLabel.text = tag
            tagContainerView.isHidden = false
        } else {
            tagContainerView.isHidden = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(mainStack)
        self.layer.cornerRadius = 12
        
        
        setupConstraints()
        
    }
    
    required init? (coder: NSCoder) {
        fatalError("Not implemented")
    }
    
}

