import UIKit

class WeekCalendarView: UIView {
    var onDateSelected: ((Date) -> Void)?
    
    var currentSelectedDate: Date {
        if let selectedRow = collectionView.indexPathsForSelectedItems?.first?.row, selectedRow < days.count {
            return days[selectedRow].date
        }
        return days.first?.date ?? Date()
    }
    
    private var days: [WeekDayModel] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: 65, height: 52)
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        
        cv.register(WeekCalendarCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()
    
    private func createSeparator() -> UIView {
        let view = UIView()
        view.backgroundColor = .appDivider
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }
    
    
    
    private func setupView() {
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.dataSource = self
        collectionView.delegate = self
        let topSeparator = createSeparator()
        let bottomSeparator = createSeparator()
        
        let collectionStackView: UIStackView = UIStackView(arrangedSubviews: [topSeparator, collectionView, bottomSeparator])
        collectionStackView.axis = .vertical
        collectionStackView.spacing = 8
        collectionStackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(collectionStackView)
        
        NSLayoutConstraint.activate([
            collectionStackView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            collectionStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func updateDays(_ newDays: [WeekDayModel]) {
        self.days = newDays
        collectionView.reloadData()
        
        if !days.isEmpty {
            let firstIndexPath = IndexPath(item: 0, section: 0)
            collectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .left)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        generateCurrentWeek()
    }
    
    func generateCurrentWeek(baseDate: Date = Date()) {
        var cal = Calendar(identifier: .gregorian)
        cal.firstWeekday = 2 
        cal.locale = Locale(identifier: "ru_RU")
        
        guard let weekInterval = cal.dateInterval(of: .weekOfYear, for: baseDate) else { return }
        
        let dayNames = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
        var weekDays: [WeekDayModel] = []
        
        for i in 0..<7 {
            if let date = cal.date(byAdding: .day, value: i, to: weekInterval.start) {
                let dayNumber = "\(cal.component(.day, from: date))"
                let dayName = dayNames[i]
                weekDays.append(WeekDayModel(date: date, dayofWeek: dayName, dayOfMonth: dayNumber))
            }
        }
        
        self.days = weekDays
        collectionView.reloadData()
        
        let targetWeekday = cal.component(.weekday, from: baseDate)
        let selectedIndex = targetWeekday == 1 ? 6 : targetWeekday - 2
        
        if selectedIndex >= 0 && selectedIndex < days.count {
            let indexPath = IndexPath(item: selectedIndex, section: 0)
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
}

extension WeekCalendarView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? WeekCalendarCell ?? WeekCalendarCell()
        cell.setDays(dayOfWeek: days[indexPath.row].dayofWeek, dayOfMonth: days[indexPath.row].dayOfMonth)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedDate = days[indexPath.row].date
        onDateSelected?(selectedDate)
    }
}



