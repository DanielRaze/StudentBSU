import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        navigationItem.hidesBackButton = false
        
        tabBar.tintColor = .appPrimary
        tabBar.unselectedItemTintColor = .appTextSecondary
        tabBar.backgroundColor = .appCardBackground
        
        let homeVC = ScheduleViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Расписание", image: .scheduleIconUnselected, selectedImage: .scheduleIcon)
        
        let examVC = ExamViewController()
        examVC.tabBarItem = UITabBarItem(title: "Экзамены", image: .examIconUnselected, selectedImage: .examIcon)
        
        let deadlineVC = DeadlineViewController()
        deadlineVC.tabBarItem = UITabBarItem(title: "Дедлайны", image: .deadlineIconUnselected, selectedImage: .deadlineIcon)
        
        let notesVC = NotesViewController()
        notesVC.tabBarItem = UITabBarItem(title: "Заметки", image: .notesIconUnselected, selectedImage: .notesIcon)
        
        let notesNav = UINavigationController(rootViewController: notesVC)
        
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(title: "Профиль", image: .profileIconUnselected, selectedImage: .profileIcon)
        
        viewControllers = [homeVC, examVC, deadlineVC, notesNav, profileVC]
    }
}
