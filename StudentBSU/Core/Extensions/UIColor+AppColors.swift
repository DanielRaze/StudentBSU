import UIKit
extension UIColor {
    
    // MARK: - 1. Основные брендовые цвета (Brand & Accent)
    
    /// Фирменный синий цвет БГУ (для кнопок, активных иконок, шапок)
    static let appPrimary = UIColor.dynamicColor(
        light: UIColor(hex: "#195AB4"),
        dark: UIColor(hex: "#3B82F6")
    )
    
    /// Темно-синий цвет (из твоего градиента Splash/Login)
    static let appDarkBlue = UIColor(hex: "#121C52")
    
    /// Яркий синий цвет (нижняя часть градиента Splash/Login)
    static let appLightBlue = UIColor(hex: "#195AB4")
    
    
    // MARK: - 2. Фоновые цвета (Backgrounds)
    
    /// Основной фон экранов (мягкий светло-серый в светлой теме, глубокий темный в темной)
    static let appBackground = UIColor.dynamicColor(
        light: UIColor(hex: "#F4F6F9"),
        dark: UIColor(hex: "#121214")
    )
    
    /// Фон белых карточек/ячеек
    static let appCardBackground = UIColor.dynamicColor(
        light: .white,
        dark: UIColor(hex: "#1C1C1E")
    )
    
    /// Фон для бейджей, поиска и подложек инпутов
    static let appSecondaryBackground = UIColor.dynamicColor(
        light: UIColor(hex: "#E9ECF2"),
        dark: UIColor(hex: "#2C2C2E")
    )
    
    static let appDormitoryBackground = UIColor(hex: "#FF9500").withAlphaComponent(0.1)
    
    
    // MARK: - 3. Цвета текста (Typography)
    
    /// Главный текст и заголовки
    static let appTextPrimary = UIColor.dynamicColor(
        light: UIColor(hex: "#1A1D20"),
        dark: UIColor(hex: "#F8FAFC")
    )
    
    /// Второстепенный текст (подзаголовки, дни недели)
    static let appTextSecondary = UIColor.dynamicColor(
        light: UIColor(hex: "#717B8A"),
        dark: UIColor(hex: "#94A3B8")
    )
    
    /// Третичный текст (аудитории, преподаватели, неактивные подписи)
    static let appTextTertiary = UIColor.dynamicColor(
        light: UIColor(hex: "#9CA3AF"),
        dark: UIColor(hex: "#64748B")
    )
    
    
    // MARK: - 4. Статусы и срочность (Дедлайны, Экзамены, Пары)
    
    /// Красный (срочно / 1-3 дня до экзамена / лекция)
    static let appRed = UIColor(hex: "#EF4444")
    
    /// Оранжевый (средняя срочность / 4-7 дней / семинар)
    static let appOrange = UIColor(hex: "#F59E0B")
    
    /// Зеленый (сдано / лабораторная / много времени)
    static let appGreen = UIColor(hex: "#10B981")
    
    /// Фиолетовый (практика / зачеты)
    static let appPurple = UIColor(hex: "#8B5CF6")
    
    
    // MARK: - 5. Разделители и тени
    
    /// Цвет тонких разделителей
    static let appDivider = UIColor.dynamicColor(
        light: UIColor.black.withAlphaComponent(0.08),
        dark: UIColor.white.withAlphaComponent(0.12)
    )
    
    // MARK: - 6. Цвета заметок (Пастельные)
    
    static let appNoteYellow = UIColor.dynamicColor(
        light: UIColor(hex: "#FFF7D1"),
        dark: UIColor(hex: "#3D3922")
    )
    
    static let appNoteGreen = UIColor.dynamicColor(
        light: UIColor(hex: "#E2F4D9"),
        dark: UIColor(hex: "#263B25")
    )
    
    static let appNoteBlue = UIColor.dynamicColor(
        light: UIColor(hex: "#DDF2FD"),
        dark: UIColor(hex: "#1E3547")
    )
    
    static let appNotePink = UIColor.dynamicColor(
        light: UIColor(hex: "#FFE1E8"),
        dark: UIColor(hex: "#4A252E")
    )
    
    static let appNotePurple = UIColor.dynamicColor(
        light: UIColor(hex: "#EAE4F2"),
        dark: UIColor(hex: "#302B40")
    )
    
    static let appNoteMint = UIColor.dynamicColor(
        light: UIColor(hex: "#D8F2EA"),
        dark: UIColor(hex: "#1D3B34")
    )
}

extension UIColor {
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        }
    }
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
