import UIKit

class DeadlineViewController: UIViewController {
    
    enum DeadlineSection: Int, CaseIterable {
        case active = 0
        case completed = 1
        
        var sectionTitle: String {
            switch self {
            case .active:
                return "АКТИВНЫЕ ДЕДЛАЙНЫ"
            case .completed:
                return "ЗАВЕРШЕННЫЕ ДЕДЛАЙНЫ"
            }
        }
    }
    
    private var completedCards: [DeadlineModel] = [] {
        didSet {
            updateStats()
        }
    }
    
    private var activeCards: [DeadlineModel] = [] {
        didSet {
            updateStats()
        }
    }
    
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Дедлайны"
        label.textColor = .appTextPrimary
        return label
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("+ Добавить", for: .normal)
        button.setTitleColor(.appPrimary, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addDeadlineTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var topPanelStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, addButton])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .appDivider
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var allCard = createStatView(value: completedCards.count + activeCards.count, title: "Всего", color: .appPrimary)
    private lazy var activeCard = createStatView(value: activeCards.count, title: "Активных", color: .appOrange)
    private lazy var completedCard = createStatView(value: completedCards.count, title: "Готово", color: .appGreen)
    
    private lazy var statStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [allCard, activeCard, completedCard])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var activeTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(DeadlineTableCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private func createStatView(value: Int, title: String, color: UIColor) -> StatCardView {
        let statCard = StatCardView()
        statCard.configure(value: String(value), title: title, color: color)
        statCard.translatesAutoresizingMaskIntoConstraints = false
        return statCard
    }
    
    private func updateStats() {
        let total = activeCards.count + completedCards.count
        allCard.updateValue(total)
        activeCard.updateValue(activeCards.count)
        completedCard.updateValue(completedCards.count)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topPanelStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            topPanelStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topPanelStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            separatorView.topAnchor.constraint(equalTo: topPanelStack.bottomAnchor, constant: 10),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            statStack.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 16),
            statStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            activeTableView.topAnchor.constraint(equalTo: statStack.bottomAnchor, constant: 10),
            activeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            activeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            activeTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc private func addDeadlineTapped() {
        let addVC = AddDeadlineView()
        
        addVC.onDeadlineAdded = {[weak self] newDeadline in
            guard let self = self else { return }
            
            self.activeCards.append(newDeadline)
            self.activeCards.sort { $0.date < $1.date }
            
            DeadlineStorage.shared.saveActive(self.activeCards)
            self.activeTableView.reloadData()
        }
        
        present(addVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        
        activeTableView.backgroundColor = .clear
        activeTableView.dataSource = self
        activeTableView.delegate = self
        
        view.addSubview(topPanelStack)
        view.addSubview(separatorView)
        view.addSubview(statStack)
        view.addSubview(activeTableView)
        
        self.activeCards = DeadlineStorage.shared.loadActive()
        self.completedCards = DeadlineStorage.shared.loadCompleted()
        
        setupConstraints()
        
        activeTableView.reloadData()
    }
}

extension DeadlineViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return DeadlineSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let deadlineSection = DeadlineSection(rawValue: section) else { return 0 }
        
        switch deadlineSection {
        case .active:
            return activeCards.count
        case .completed:
            return completedCards.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? DeadlineTableCell,
              let deadlineSection = DeadlineSection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        let model: DeadlineModel
        switch deadlineSection {
        case .active:
            model = activeCards[indexPath.row]
            cell.configure(with: model, isCompleted: false)
            
            cell.onToggle = {[weak self, weak tableView] in
                guard let self = self,
                        let currentIndexPath = tableView?.indexPath(for: cell)
                else { return}
                
                let item = self.activeCards.remove(at: currentIndexPath.row)
                self.completedCards.append(item)
                DeadlineStorage.shared.saveActive(self.activeCards)
                DeadlineStorage.shared.saveCompleted(self.completedCards)
                self.activeTableView.reloadData()
            }
        case .completed:
            model = completedCards[indexPath.row]
            cell.configure(with: model, isCompleted: true)
            
            cell.onToggle = {[weak self, weak tableView] in
                guard let self = self,
                        let currentIndexPath = tableView?.indexPath(for: cell)
                else { return}
                
                let item = self.completedCards.remove(at: currentIndexPath.row)
                self.activeCards.append(item)
                DeadlineStorage.shared.saveActive(self.activeCards)
                DeadlineStorage.shared.saveCompleted(self.completedCards)
                self.activeTableView.reloadData()
            }
        }
        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return}
        
        if #available(iOS 14.0, *) {
            var configuration = header.defaultContentConfiguration()
            configuration.text = DeadlineSection(rawValue: section)?.sectionTitle
            configuration.textProperties.color = .appTextSecondary
            configuration.textProperties.font = UIFont.systemFont(ofSize: 13)
            header.contentConfiguration = configuration
        }
        else{
            header.textLabel?.textColor = .appTextSecondary
            header.textLabel?.font = UIFont.systemFont(ofSize: 13)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DeadlineSection(rawValue: section)?.sectionTitle
    }
}
