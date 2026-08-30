import UIKit

class ScheduleViewController: UIViewController {
    
    private var loadTask: Task<Void, Never>?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Расписание"
        label.textColor = .appTextPrimary
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.text = "3 курс, группа 7 - РФиКТ"
        label.textColor = .appTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var calendarButton: UIButton = {
        let button = UIButton(configuration: UIButton.Configuration.filled())
        button.configuration?.baseBackgroundColor = .appPrimary
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = .calendarIcon
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var titleStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var topPanelStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleStack, calendarButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var weekCalendar = WeekCalendarView()
    
    private lazy var collectionView: UICollectionView = {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(110)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(110)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 20, bottom: 20, trailing: 20)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        cv.register(ScheduleCollectionCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    private var allSchedule: [Int: [ClassModel]] = [:]
    private var currentLessons: [ClassModel] = []
    private var selectedDate: Date = Date()
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topPanelStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            topPanelStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topPanelStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            weekCalendar.topAnchor.constraint(equalTo: topPanelStack.bottomAnchor, constant: 20),
            weekCalendar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weekCalendar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weekCalendar.heightAnchor.constraint(equalToConstant: 80),
            
            collectionView.topAnchor.constraint(equalTo: weekCalendar.bottomAnchor, constant: 12),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadOnlineSchedule() async {
        do {
            let result = try await ScheduleService.shared.fetchCurrentStudentSchedule()
                
            await MainActor.run {
                self.allSchedule = result.schedule
                    
                let scheduleDate = result.startDate ?? Date()
                self.weekCalendar.generateCurrentWeek(baseDate: scheduleDate)
                    
                self.filterLessons(for: scheduleDate)
                
                if result.isOffline {
                    self.subtitleLabel.text = "\(result.course.title), \(result.group) • ⚠️ Офлайн"
                    self.subtitleLabel.textColor = .appOrange
                } else {
                    self.subtitleLabel.text = "\(result.course.title), \(result.group) - РФиКТ"
                    self.subtitleLabel.textColor = .appTextSecondary
                }
            }
            } catch {
                print("Ошибка загрузки расписания: \(error)")
            }
        
    }
    
    private func filterLessons(for date: Date) {
        self.selectedDate = date
        let weekday = Calendar.current.component(.weekday, from: date)
        self.currentLessons = allSchedule[weekday] ?? []
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(topPanelStack)
        view.addSubview(weekCalendar)
        view.addSubview(collectionView)
        view.backgroundColor = .appBackground
        setupConstraints()
        
        collectionView.dataSource = self
        
        weekCalendar.onDateSelected = { [weak self] selectedDate in
            self?.filterLessons(for: selectedDate)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTask = Task { [weak self] in
            guard let self = self else { return }
            await loadOnlineSchedule()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadTask?.cancel()
    }
    
    
}

extension ScheduleViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentLessons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ScheduleCollectionCell ?? ScheduleCollectionCell()
        let lesson = currentLessons[indexPath.row]
        cell.configure(with: lesson)
        return cell
    }
}
