import UIKit
import CoreData

struct Note: Hashable {
    let id: UUID
    var title: String?
    var text: String?
    var tag: String?
    var date: Date
    let colorIndex: Int
    var backgroundColor: UIColor {
        let colors: [UIColor] = [.appNoteYellow, .appNoteGreen, .appNoteBlue, .appNotePink, .appNotePurple, .appNoteMint]
        return colors[colorIndex % colors.count]
    }
    
    init() {
        self.id = UUID()
        self.title = ""
        self.text = ""
        self.tag = ""
        self.date = Date()
        self.colorIndex = Int.random(in: 0...5)
    }
    
    init(entity: NoteEntity) {
        self.id = entity.id ?? UUID()
        self.title = entity.title
        self.text = entity.text
        self.tag = entity.tag
        self.date = entity.date ?? Date()
        self.colorIndex = Int(entity.colorIndex)
    }
}
