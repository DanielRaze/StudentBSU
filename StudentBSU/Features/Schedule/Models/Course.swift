enum Course: Int, CaseIterable {
    case first = 1
    case second = 2
    case third = 3
    case fourth = 4
    
    var title: String {
        return "\(self.rawValue) курс"
    }
    
    var scheduleURLString: String {
        switch self {
        case .first:
            return "https://docs.google.com/spreadsheets/d/1Wmsij8rOJAcOaPaKWnUphEghdldCRvXDqvX7am6Km4A/export?format=csv"
        case .second:
            return "https://docs.google.com/spreadsheets/d/11LI8TxCfm8zyniVfH4gCaEzzgpTlSqHWeDob5sprBxw/export?format=csv"
        case .third:
            return "https://docs.google.com/spreadsheets/d/168x4wA4BsD3Ft9LoGOOgoUKNd_pziIab_2vhXtqK0oU/export?format=csv"
        case .fourth:
            return ""
        }
    }
}

