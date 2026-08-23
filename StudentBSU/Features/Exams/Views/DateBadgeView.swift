import UIKit

class DateBadgeView: UIView {
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var monthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var mainStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dayLabel, monthLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    func setDay(day: Int){
        dayLabel.text = String(day)
    }
    
    func setMonth (month: String){
        monthLabel.text = month
    }
    
    func configure(day: String, month: String, color: UIColor){
        dayLabel.text = day
        dayLabel.textColor = color
        
        monthLabel.text = month
        monthLabel.textColor = color
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 48),
            heightAnchor.constraint(equalToConstant: 54),
            
            mainStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.addSubview(mainStack)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
}

