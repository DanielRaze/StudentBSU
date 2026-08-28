import UIKit

class ProfileViewController: UIViewController {
    
    private var themes = ["☀️ Светлая", "🌙 Тёмная", "⚙️ Как в системе"]
    
    private let profileService: ProfileServiceProtocol = ProfileService()
    
    private var selectedTheme: Int = 0
    
    private var loadTask: Task<Void, Never>?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Профиль"
        label.textColor = .appTextPrimary
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .appDivider
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }()
    
    private let authCardView: ActionCardView = {
        let actionCard = ActionCardView()
        actionCard.translatesAutoresizingMaskIntoConstraints = false
        return actionCard
    }()
    
    private let dormitoryTitle: UILabel = {
        let label = UILabel()
        label.text = "ОБЩЕЖИТИЕ"
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .appTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dormitoryCardView: ActionCardView = {
        let actionCard = ActionCardView()
        actionCard.configure(icon: UIImage(systemName: "house"), iconBackgroundColor: .appDormitoryBackground ,
                             title: "Данные недоступны",
                             subtitle: "Войдите в Студент БГУ")
        actionCard.translatesAutoresizingMaskIntoConstraints = false
        return actionCard
    }()
    
    private lazy var dormitoryStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [dormitoryTitle, dormitoryCardView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    private lazy var themeSwitch: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.layer.cornerRadius = 16
        tableView.separatorColor = .appDivider
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let notificationTitle: UILabel = {
        let label = UILabel()
        label.text = "УВЕДОМЛЕНИЯ"
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .appTextSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var notificationSettings: NotificationSettingsCardView = NotificationSettingsCardView()
    
    private lazy var notificationStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [notificationTitle, notificationSettings])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var mainStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [authCardView, dormitoryStack, themeSwitch, notificationStack])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.addSubview(mainStack)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            mainStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -30),
            mainStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            mainStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            
            mainStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
            themeSwitch.heightAnchor.constraint(equalToConstant: 250)
            
        ])
    }
    
    private func showDormitoryCard(isProvided: Bool, roomData: String) {
        if isProvided {
            dormitoryCardView.configure(icon: UIImage(systemName: "checkmark.circle.fill"), iconBackgroundColor: .appGreen,
                                 title: "Предоставлено общежитие",
                                 subtitle: roomData)
        }
        else {
            dormitoryCardView.configure(icon: UIImage(systemName: "house"), iconBackgroundColor: .appDormitoryBackground ,
                                 title: "Данные недоступны",
                                 subtitle: "Войдите в Студент БГУ")
        }
        
    }
    private func showUnauthorizedState() {
        authCardView.configure(icon: UIImage(systemName: "key.and.lock"),
                             title: "Не выполнен вход",
                             subtitle: "Войдите в студент БГУ для полного доступа",
                             buttonTitle: "Войти")
        authCardView.onToggle = { [weak self] in
            guard self != nil else { return }
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else { return}
            
            UIView.transition(with: window,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: {
                window.rootViewController = LoginViewController()
                }, completion: nil)
        }
    }
    
    private func updateAuthState() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isUserLoggedIn")
        if isLoggedIn {
            authCardView.configure(
                        icon: UIImage(systemName: "person.circle.fill"),
                        title: "Загрузка профиля...",
                        subtitle: "Студент БГУ",
                        detailText: nil,
                        buttonTitle: "")
            
            Task{ [weak self] in
                guard let self = self else { return }
                do {
                    let profile = try await profileService.fetchProfileData()
                    self.displayStudentProfile(profile)
                }
                catch let error as NetworkError {
                    if case .unauthorized = error {
                        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                        self.showUnauthorizedState()
                    }
                }
                catch {
                    print("Ошибка сети: \(error)")
                }
            }
        }
        else{
           showUnauthorizedState()
        }
    }
    
    private func updateDormitory() {
        Task{
            let (isProvided, roomData) = await profileService.fetchDormitoryStatus()
            showDormitoryCard(isProvided: isProvided, roomData: roomData ?? "")
        }
    }
    
    private func displayStudentProfile(_ model: StudentProfileModel){
        authCardView.configure(
                icon: UIImage(systemName: "person.circle.fill"),
                title: model.fullName,
                subtitle: model.course + "·" + model.group,
                detailText: model.specialization + "·" + model.faculty,
                buttonTitle: "Онлайн"
            )
        
        if let photoURL = model.photoURL {
            Task { [weak self] in
                if let (data, _) = try? await URLSession.shared.data(from: photoURL),
                   let photo = UIImage(data: data) {
                    await MainActor.run {
                        self?.authCardView.setAvatarImage(image: photo)
                    }
                }
            }
        }
    }
    
    private func applyAppTheme(index: Int) {
        let style: UIUserInterfaceStyle
        
        switch index {
        case 0:
            style = .light
        case 1:
            style = .dark
        default:
            style = .unspecified
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as?
                UIWindowScene else { return}
        windowScene.windows.forEach { window in
            window.overrideUserInterfaceStyle = style
        }
        
        UserDefaults.standard.set(index, forKey: "appSelectedTheme")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        
        themeSwitch.dataSource = self
        themeSwitch.delegate = self
        themeSwitch.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        themeSwitch.isScrollEnabled = false
        
        view.addSubview(titleLabel)
        view.addSubview(separatorView)
        view.addSubview(scrollView)
        
        selectedTheme = UserDefaults.standard.integer(forKey: "appSelectedTheme")
        applyAppTheme(index: selectedTheme)
        
        setupConstraints()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTask = Task { [weak self] in
            guard let self = self else { return }
            updateAuthState()
            updateDormitory()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        loadTask?.cancel()
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.tintColor = .appPrimary
        
        cell.accessoryType = (indexPath.row == selectedTheme) ? .checkmark : .none
        
        
        var content = cell.defaultContentConfiguration()
        content.text = themes[indexPath.row]
        content.textProperties.color = .appTextPrimary
        content.textProperties.font = UIFont.systemFont(ofSize: 16)
        cell.contentConfiguration = content
    
        var backgroundConfig = UIBackgroundConfiguration.listCell()
        backgroundConfig.backgroundColor = .appCardBackground
        cell.backgroundConfiguration = backgroundConfig
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return}
        
        if #available(iOS 14.0, *) {
            var configuration = header.defaultContentConfiguration()
            configuration.text = "ВНЕШНИЙ ВИД"
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
        return "ВНЕШНИЙ ВИД"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedTheme = indexPath.row
        
        tableView.reloadData()
        
        applyAppTheme(index: selectedTheme)
    }
}
