import UIKit

class ExamViewController: UIViewController {
    enum examsType: Int, CaseIterable {
        case exams = 0
        case tests = 1
    }
    
    private var loadTask: Task<Void, Never>?
    
    private var currentSessionType: examsType = .exams
    
   
    private var allExams: [ExamModel] = []
        
    private var upcomingTests: [ExamModel] = []
    private var upcomingExams: [ExamModel] = []
    private var passedTests: [ExamModel] = []
    private var passedExams: [ExamModel] = []
    
    private var currentSemester: Int = 5
   
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Сессия"
        label.textColor = .appTextPrimary
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = "Январь - февраль 2026"
        label.textColor = .appTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var semesterButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "Семестр 5"
        config.image = UIImage(systemName: "chevron.down")
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.buttonSize = .small
        
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.showsMenuAsPrimaryAction = true
        button.menu = createSemesterMenu(selected: currentSemester)
        
        return button
    }()
    
    private lazy var titleRow: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, semesterButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var titleStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleRow, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .appDivider
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["Экзамены", "Зачеты"]
        let segmented = UISegmentedControl(items: items)
        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        segmented.translatesAutoresizingMaskIntoConstraints = false
        segmented.backgroundColor = .appSecondaryBackground
        segmented.selectedSegmentTintColor = .appCardBackground
        return segmented
    }()
    
    private lazy var mainTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(ExamTableCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private lazy var segmentedStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [segmentedControl, mainTableView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        currentSessionType = examsType(rawValue: sender.selectedSegmentIndex) ?? .exams
        
        mainTableView.reloadData()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            titleStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            separatorView.topAnchor.constraint(equalTo: titleStack.bottomAnchor, constant: 20),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            segmentedStack.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 14),
            segmentedStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            segmentedStack.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadExams() async {
            do {
                let result = try await ExamMockGenerator.shared.getExams(for: currentSemester)
                self.allExams = result.exams
                
                self.upcomingTests = allExams.upcomingTests
                self.upcomingExams = allExams.upcomingExams
                self.passedTests = allExams.passedTests
                self.passedExams = allExams.passedExams
                
                await MainActor.run {
                    mainTableView.reloadData()
                    
                    if result.isOffline {
                        self.subtitleLabel.text = "⚠️ Офлайн (Показан кэш)"
                        self.subtitleLabel.textColor = .appOrange
                    } else {
                        self.subtitleLabel.text = "Расписание сессии"
                        self.subtitleLabel.textColor = .appTextSecondary
                    }
                }
                
            } catch {
                print("Ошибка при загрузке экзаменов: \(error)")
            }
    }
    
    private func semesterSelected(_ sem: Int) {
        currentSemester = sem
        
        semesterButton.configuration?.title = "Семестр \(sem)"
        semesterButton.menu = createSemesterMenu(selected: sem)
        UserDefaults.standard.set(sem, forKey: "currentSemester")
        
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            await self?.loadExams()
        }
    }
    
    private func createSemesterMenu(selected: Int) -> UIMenu {
        let actions = (1...8).map { sem in
            UIAction(title: "Семестр \(sem)", state: sem == selected ? .on : .off) { [weak self] _ in
                self?.semesterSelected(sem)
            }
        }
        return UIMenu(title: "Выберите семестр", children: actions)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        
        
        mainTableView.dataSource = self
        mainTableView.delegate = self
        mainTableView.backgroundColor = .clear
        
        let saved = UserDefaults.standard.integer(forKey: "currentSemester")
        currentSemester = saved == 0 ? 5 : saved
        semesterButton.configuration?.title = "Семестр \(currentSemester)"
        
        view.addSubview(titleStack)
        view.addSubview(separatorView)
        view.addSubview(segmentedStack)
        
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTask = Task { [weak self] in
            guard let self = self else { return }
            await loadExams()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadTask?.cancel()
    }
}

extension ExamViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return currentSessionType == .exams ? upcomingExams.count : upcomingTests.count
        }
        else {
            return currentSessionType == .exams ? passedExams.count : passedTests.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ExamTableCell else {
            return UITableViewCell()
        }
        
        let model: ExamModel
        if indexPath.section == 0 {
            model = (currentSessionType == .exams) ? upcomingExams[indexPath.row] : upcomingTests[indexPath.row]
        }
        else {
            model = (currentSessionType == .exams) ? passedExams[indexPath.row] : passedTests[indexPath.row]
        }
        
        let isCompleted = (indexPath.section == 1) ? true : false
        cell.configure(from: model, isCompleted: isCompleted)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return}
        
        if #available(iOS 14.0, *) {
            var configuration = header.defaultContentConfiguration()
            configuration.text = (section == 0) ? "ПРЕДСТОЯЩИЕ" : "СДАННЫЕ"
            configuration.textProperties.color = .appTextSecondary
            configuration.textProperties.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            header.contentConfiguration = configuration
        }
        else{
            header.textLabel?.textColor = .appTextSecondary
            header.textLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "ПРЕДСТОЯЩИЕ" : "СДАННЫЕ"
    }
}

