import UIKit

class WeekCalendarCell: UICollectionViewCell {
    private lazy var dayOfWeek: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .appTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var dayOfMonth: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textColor = .appTextPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dayStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dayOfWeek, dayOfMonth])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.backgroundColor = .appPrimary
                dayOfMonth.textColor = .white
                dayOfWeek.textColor = UIColor.white.withAlphaComponent(0.8)
            } else {
                contentView.backgroundColor = .appCardBackground
                dayOfMonth.textColor = .appTextPrimary
                dayOfWeek.textColor = .appTextSecondary
            }
        }
    }
    
    func setDays(dayOfWeek: String, dayOfMonth: String){
        self.dayOfMonth.text = dayOfMonth
        self.dayOfWeek.text = dayOfWeek
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.08
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 8.0
        self.layer.masksToBounds = false
        
        self.layer.shadowPath = UIBezierPath(
                roundedRect: self.bounds,
                cornerRadius: self.contentView.layer.cornerRadius
            ).cgPath
        
        contentView.addSubview(dayStack)
        NSLayoutConstraint.activate([
            dayStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
}
